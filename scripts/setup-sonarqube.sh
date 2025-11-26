#!/bin/bash

# ============================================
# Script de Configuración de SonarQube
# Taller Kiro - MCP Servers Integration
# ============================================

set -e  # Exit on error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables de configuración
SONAR_HOST_URL="http://localhost:9000"
SONAR_TOKEN="${SONAR_TOKEN:-}"
PROJECT_KEY="kiro-workshop-task-manager"
PROJECT_NAME="Task Manager - Kiro Workshop"
MAX_WAIT_TIME=180  # 3 minutos máximo de espera

# Función para imprimir mensajes con color
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Función para verificar si Docker está instalado
check_docker() {
    print_info "Verificando Docker..."
    if ! command -v docker &> /dev/null; then
        print_error "Docker no está instalado"
        echo "💡 Instalar Docker desde: https://www.docker.com/get-started"
        exit 1
    fi
    print_success "Docker está instalado"
}

# Función para verificar si SonarQube está ejecutándose
check_sonarqube_running() {
    print_info "Verificando si SonarQube está ejecutándose..."
    
    if docker ps | grep -q "sonarqube-mcp-server"; then
        print_success "Contenedor SonarQube está ejecutándose"
        return 0
    else
        print_warning "Contenedor SonarQube no está ejecutándose"
        return 1
    fi
}

# Función para iniciar SonarQube
start_sonarqube() {
    print_info "Iniciando SonarQube con Docker Compose..."
    
    if [ ! -f "docker-compose.yml" ]; then
        print_error "Archivo docker-compose.yml no encontrado"
        exit 1
    fi
    
    docker-compose up -d
    print_success "SonarQube iniciado"
}

# Función para esperar a que SonarQube esté listo
wait_for_sonarqube() {
    print_info "Esperando a que SonarQube esté listo..."
    
    local elapsed=0
    local interval=5
    
    while [ $elapsed -lt $MAX_WAIT_TIME ]; do
        if curl -s "$SONAR_HOST_URL/api/system/status" | grep -q '"status":"UP"'; then
            print_success "SonarQube está listo en $SONAR_HOST_URL"
            return 0
        fi
        
        echo -n "."
        sleep $interval
        elapsed=$((elapsed + interval))
    done
    
    echo ""
    print_error "SonarQube no respondió después de $MAX_WAIT_TIME segundos"
    print_info "Verificar logs con: docker logs sonarqube"
    exit 1
}

# Función para solicitar token al usuario
prompt_for_token() {
    echo ""
    print_info "Abriendo SonarQube en el navegador..."
    
    # Intentar abrir el navegador automáticamente
    if command -v open &> /dev/null; then
        # macOS
        open "$SONAR_HOST_URL" 2>/dev/null || true
    elif command -v xdg-open &> /dev/null; then
        # Linux
        xdg-open "$SONAR_HOST_URL" 2>/dev/null || true
    fi
    
    echo ""
    echo "📝 Pasos para generar un token:"
    echo "   1. En el navegador, ir a: $SONAR_HOST_URL"
    echo "   2. Login: admin/admin (cambiar contraseña si es primera vez)"
    echo "   3. Click en el icono de usuario (arriba derecha)"
    echo "   4. Ir a: My Account → Security"
    echo "   5. En 'Generate Tokens':"
    echo "      - Name: kiro-workshop-token"
    echo "      - Type: User Token"
    echo "      - Expires in: 30 days"
    echo "   6. Click 'Generate'"
    echo "   7. Copiar el token generado"
    echo ""
    
    # Solicitar token al usuario
    read -p "Pega tu token aquí (o presiona Enter para continuar sin token): " user_token
    
    if [ -n "$user_token" ]; then
        # Limpiar espacios en blanco
        user_token=$(echo "$user_token" | tr -d '[:space:]')
        SONAR_TOKEN="$user_token"
        print_success "Token capturado"
        
        # Guardar en variable de entorno para esta sesión
        export SONAR_TOKEN="$user_token"
        
        # Ofrecer guardarlo permanentemente
        echo ""
        read -p "¿Deseas guardar este token para futuras ejecuciones? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Agregar al archivo de perfil del shell
            local shell_profile=""
            if [ -f "$HOME/.zshrc" ]; then
                shell_profile="$HOME/.zshrc"
            elif [ -f "$HOME/.bashrc" ]; then
                shell_profile="$HOME/.bashrc"
            elif [ -f "$HOME/.bash_profile" ]; then
                shell_profile="$HOME/.bash_profile"
            fi
            
            if [ -n "$shell_profile" ]; then
                echo "" >> "$shell_profile"
                echo "# SonarQube Token - Kiro Workshop" >> "$shell_profile"
                echo "export SONAR_TOKEN=\"$user_token\"" >> "$shell_profile"
                print_success "Token guardado en $shell_profile"
                print_info "Ejecuta 'source $shell_profile' o reinicia tu terminal para aplicar"
            else
                print_warning "No se pudo detectar el archivo de perfil del shell"
                echo "Puedes agregar manualmente: export SONAR_TOKEN=\"$user_token\""
            fi
        fi
    else
        print_warning "Continuando sin token"
        return 1
    fi
    
    return 0
}

# Función para verificar token
check_token() {
    print_info "Verificando token de SonarQube..."
    
    if [ -z "$SONAR_TOKEN" ]; then
        print_warning "Token de SonarQube no configurado"
        echo ""
        
        # Preguntar si quiere ingresar el token ahora
        read -p "¿Deseas ingresar el token ahora? (y/n) " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if prompt_for_token; then
                # Token capturado, continuar con validación
                :
            else
                # Usuario decidió continuar sin token
                print_warning "Continuando sin token - algunas funciones estarán limitadas"
                return 1
            fi
        else
            print_warning "Continuando sin token - algunas funciones estarán limitadas"
            echo ""
            echo "💡 Para configurar el token más tarde:"
            echo "   export SONAR_TOKEN='tu-token-aqui'"
            echo "   ./setup-sonarqube.sh"
            echo ""
            return 1
        fi
    else
        print_success "Token configurado"
    fi
    
    # Validar token si existe
    if [ -n "$SONAR_TOKEN" ]; then
        print_info "Validando token..."
        if curl -s -u "$SONAR_TOKEN:" "$SONAR_HOST_URL/api/authentication/validate" | grep -q "valid.*true"; then
            print_success "Token válido"
            return 0
        else
            print_error "Token inválido o expirado"
            echo ""
            read -p "¿Deseas ingresar un nuevo token? (y/n) " -n 1 -r
            echo
            
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                # Limpiar token inválido
                SONAR_TOKEN=""
                if prompt_for_token; then
                    # Validar el nuevo token
                    if curl -s -u "$SONAR_TOKEN:" "$SONAR_HOST_URL/api/authentication/validate" | grep -q "valid.*true"; then
                        print_success "Nuevo token válido"
                        return 0
                    else
                        print_error "El nuevo token también es inválido"
                        exit 1
                    fi
                else
                    exit 1
                fi
            else
                exit 1
            fi
        fi
    fi
}

# Función para verificar si el proyecto existe
check_project_exists() {
    print_info "Verificando si el proyecto existe en SonarQube..."
    
    if [ -z "$SONAR_TOKEN" ]; then
        print_warning "Sin token, no se puede verificar el proyecto"
        return 1
    fi
    
    local response=$(curl -s -u "$SONAR_TOKEN:" \
        "$SONAR_HOST_URL/api/projects/search?projects=$PROJECT_KEY")
    
    if echo "$response" | grep -q "\"key\":\"$PROJECT_KEY\""; then
        print_success "Proyecto '$PROJECT_KEY' ya existe"
        return 0
    else
        print_info "Proyecto '$PROJECT_KEY' no existe"
        return 1
    fi
}

# Función para crear el proyecto en SonarQube
create_project() {
    print_info "Creando proyecto en SonarQube..."
    
    if [ -z "$SONAR_TOKEN" ]; then
        print_warning "Sin token, no se puede crear el proyecto"
        echo ""
        echo "💡 Crear proyecto manualmente:"
        echo "   1. Ir a: $SONAR_HOST_URL"
        echo "   2. Click en 'Create Project'"
        echo "   3. Project key: $PROJECT_KEY"
        echo "   4. Display name: $PROJECT_NAME"
        echo ""
        return 1
    fi
    
    # Crear proyecto usando la API
    local response=$(curl -s -w "\n%{http_code}" -u "$SONAR_TOKEN:" \
        -X POST "$SONAR_HOST_URL/api/projects/create" \
        -d "project=$PROJECT_KEY" \
        -d "name=$PROJECT_NAME")

    echo "Rspuesta: $response"
    
    local http_code=$(echo "$response" | tail -n 1)
    local body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "200" ]; then
        print_success "Proyecto creado exitosamente"
        echo "   Project Key: $PROJECT_KEY"
        echo "   Project Name: $PROJECT_NAME"
        echo "   URL: $SONAR_HOST_URL/dashboard?id=$PROJECT_KEY"
        return 0
    else
        print_error "Error al crear proyecto (HTTP $http_code)"
        echo "$body" | head -5
        echo ""
        echo "💡 Crear proyecto manualmente:"
        echo "   1. Ir a: $SONAR_HOST_URL"
        echo "   2. Click en 'Create Project'"
        echo "   3. Project key: $PROJECT_KEY"
        echo "   4. Display name: $PROJECT_NAME"
        echo ""
        return 1
    fi
}

# Función para verificar sonar-scanner
check_sonar_scanner() {
    print_info "Verificando sonar-scanner..."
    
    if command -v sonar-scanner &> /dev/null; then
        print_success "sonar-scanner está instalado ($(sonar-scanner --version | head -n 1))"

    else
        print_warning "sonar-scanner no está instalado localmente"
        print_info "Se usará Docker para ejecutar el análisis"

    fi
}

# Función para ejecutar análisis con sonar-scanner local
run_analysis_local() {
    print_info "Ejecutando análisis con sonar-scanner local..."
    echo ""
    
    local sonar_args=(
        "-Dsonar.projectKey=$PROJECT_KEY"
        "-Dsonar.projectName=$PROJECT_NAME"
        "-Dsonar.sources=src"
        "-Dsonar.exclusions=node_modules/**,cdk/**,*.md,.git/**,venv/**,backup-original/**,soluciones-referencia/**,scripts/**,docs/**"
        "-Dsonar.javascript.file.suffixes=.js,.jsx"
        "-Dsonar.css.file.suffixes=.css"
        "-Dsonar.html.file.suffixes=.html,.htm"
        "-Dsonar.host.url=$SONAR_HOST_URL"
    )
    
    if [ -n "$SONAR_TOKEN" ]; then
        sonar_args+=("-Dsonar.login=$SONAR_TOKEN")
    fi
    
    sonar-scanner "${sonar_args[@]}"
}

# Función para ejecutar análisis con Docker
run_analysis_docker() {
    print_info "Ejecutando análisis con Docker..."
    echo ""
    
    docker run --rm \
        --network kiro-workshop_kiro-workshop \
        -e SONAR_HOST_URL="http://sonarqube:9000" \
        -e SONAR_TOKEN="$SONAR_TOKEN" \
        -v "$(pwd):/usr/src" \
        sonarsource/sonar-scanner-cli \
        -Dsonar.projectKey=$PROJECT_KEY \
        -Dsonar.projectName="$PROJECT_NAME" \
        -Dsonar.sources=src \
        -Dsonar.exclusions="node_modules/**,cdk/**,*.md,.git/**,venv/**,backup-original/**,soluciones-referencia/**,scripts/**,docs/**"
}

# Función para ejecutar análisis (decide entre local o Docker)
run_analysis() {
    if command -v sonar-scanner &> /dev/null; then
        if run_analysis_local; then
            print_success "Análisis completado exitosamente"
            return 0
        else
            print_error "Análisis falló"
            return 1
        fi
    else
        print_info "Usando Docker para ejecutar sonar-scanner..."
        if run_analysis_docker; then
            print_success "Análisis completado exitosamente"
            return 0
        else
            print_error "Análisis falló"
            return 1
        fi
    fi
}

# Función para mostrar resumen
show_summary() {
    echo ""
    echo "=================================================="
    echo "📊 RESUMEN DEL ANÁLISIS"
    echo "=================================================="
    echo ""
    print_success "Configuración completada exitosamente"
    echo ""
    echo "🌐 URLs importantes:"
    echo "   Dashboard:  $SONAR_HOST_URL/dashboard?id=$PROJECT_KEY"
    echo "   Issues:     $SONAR_HOST_URL/project/issues?id=$PROJECT_KEY"
    echo "   Measures:   $SONAR_HOST_URL/component_measures?id=$PROJECT_KEY"
    echo ""
    echo "📈 Problemas esperados: 27+"
    echo "   🔴 Bloqueadores: 4"
    echo "   🟠 Críticos: 5"
    echo "   🟡 Mayores: 10+"
    echo "   🔵 Menores: 8+"
    echo ""
    echo "💡 Próximos pasos:"
    echo "   1. Abrir dashboard en navegador"
    echo "   2. Revisar problemas detectados"
    echo "   3. Documentar top 5 problemas críticos"
    echo "   4. Continuar con Ejercicio 2 (Chrome DevTools)"
    echo ""
}

# Función para troubleshooting
show_troubleshooting() {
    echo ""
    echo "🔧 TROUBLESHOOTING"
    echo "=================================================="
    echo ""
    echo "Si SonarQube no inicia:"
    echo "  docker logs sonarqube"
    echo "  docker-compose restart"
    echo ""
    echo "Si el puerto 9000 está ocupado:"
    echo "  lsof -i :9000"
    echo "  # Matar proceso o cambiar puerto en docker-compose.yml"
    echo ""
    echo "Si el análisis falla:"
    echo "  # Verificar conectividad"
    echo "  curl $SONAR_HOST_URL/api/system/status"
    echo ""
    echo "  # Verificar token"
    echo "  curl -H \"Authorization: Bearer \$SONAR_TOKEN\" \\"
    echo "       $SONAR_HOST_URL/api/authentication/validate"
    echo ""
    echo "Para limpiar y reiniciar:"
    echo "  docker-compose down -v"
    echo "  docker-compose up -d"
    echo ""
}

# Función principal
main() {
    echo ""
    echo "=================================================="
    echo "🚀 SETUP SONARQUBE - TALLER KIRO"
    echo "=================================================="
    echo ""
    
    # 1. Verificar Docker
    check_docker
    
    # 2. Verificar/Iniciar SonarQube
    if ! check_sonarqube_running; then
        start_sonarqube
    fi
    
    # 3. Esperar a que SonarQube esté listo
    wait_for_sonarqube
    
    # 4. Verificar token
    check_token
    
    # 5. Verificar/Crear proyecto
    if ! check_project_exists; then
        print_info "El proyecto no existe, creándolo..."
        if ! create_project; then
            print_warning "No se pudo crear el proyecto automáticamente"
            print_info "El análisis continuará, pero puede fallar si el proyecto no existe"
        fi
    fi
    
    # 6. Verificar sonar-scanner
    check_sonar_scanner
    
    # 7. Ejecutar análisis
    if run_analysis; then
        show_summary
    else
        print_error "El análisis falló. Ver troubleshooting:"
        show_troubleshooting
        exit 1
    fi
}

# Manejo de señales
trap 'echo ""; print_warning "Script interrumpido por el usuario"; exit 130' INT TERM

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
