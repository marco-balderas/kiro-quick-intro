#!/bin/bash

# ============================================
# Script de Despliegue AWS CDK
# Taller Kiro - MCP Servers Integration
# ============================================

set -e  # Exit on error

# Variables de configuración
STACK_NAME="KiroWorkshopTaskManager"
REGION="${AWS_REGION:-us-east-1}"
CDK_DIR="../cdk"
ORIGINAL_DIR=$(pwd)

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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

print_step() {
    echo -e "${CYAN}▶️  $1${NC}"
}

# Función para mostrar banner
show_banner() {
    echo ""
    echo "=================================================="
    echo "🏗️  AWS CDK DEPLOYMENT - TALLER KIRO"
    echo "=================================================="
    echo ""
    echo "Stack:  $STACK_NAME"
    echo "Region: $REGION"
    echo ""
}

# Verificar prerrequisitos
check_prerequisites() {
    print_step "Verificando prerrequisitos..."
    echo ""
    
    local all_ok=true
    
    # Verificar AWS CLI
    if command -v aws &> /dev/null; then
        local aws_version=$(aws --version 2>&1 | cut -d' ' -f1)
        print_success "AWS CLI instalado ($aws_version)"
    else
        print_error "AWS CLI no está instalado"
        echo "   💡 Instalar con: pip install awscli"
        all_ok=false
    fi
    
    # Verificar CDK
    if command -v cdk &> /dev/null; then
        local cdk_version=$(cdk --version 2>&1)
        print_success "AWS CDK instalado ($cdk_version)"
    else
        print_error "AWS CDK no está instalado"
        echo "   💡 Instalar con: npm install -g aws-cdk"
        all_ok=false
    fi
    
    # Verificar Python
    if command -v python3 &> /dev/null; then
        local python_version=$(python3 --version 2>&1)
        print_success "Python instalado ($python_version)"
    else
        print_error "Python 3 no está instalado"
        all_ok=false
    fi
    
    # Verificar Node.js (requerido por CDK)
    if command -v node &> /dev/null; then
        local node_version=$(node --version 2>&1)
        print_success "Node.js instalado ($node_version)"
    else
        print_warning "Node.js no está instalado (requerido por CDK)"
        echo "   💡 Instalar desde: https://nodejs.org/"
    fi
    
    # Verificar credenciales AWS
    print_info "Verificando credenciales AWS..."
    if aws sts get-caller-identity &> /dev/null; then
        local account_id=$(aws sts get-caller-identity --query Account --output text)
        local user_arn=$(aws sts get-caller-identity --query Arn --output text)
        print_success "Credenciales AWS configuradas"
        echo "   Account: $account_id"
        echo "   User:    $user_arn"
        echo "   Region:  $REGION"
    else
        print_error "Credenciales AWS no configuradas o inválidas"
        echo "   💡 Configurar con: aws configure"
        all_ok=false
    fi
    
    echo ""
    
    if [ "$all_ok" = false ]; then
        print_error "Algunos prerrequisitos no están cumplidos"
        exit 1
    fi
    
    print_success "Todos los prerrequisitos verificados"
    echo ""
}

# Configurar entorno Python
setup_python_env() {
    print_step "Configurando entorno Python..."
    echo ""
    
    cd "$CDK_DIR"
    
    # Crear entorno virtual si no existe
    if [ ! -d "venv" ]; then
        print_info "Creando entorno virtual Python..."
        python3 -m venv venv
        print_success "Entorno virtual creado"
    else
        print_info "Entorno virtual ya existe"
    fi
    
    # Activar entorno virtual
    print_info "Activando entorno virtual..."
    source venv/bin/activate
    
    # Actualizar pip
    print_info "Actualizando pip..."
    pip install --upgrade pip --quiet
    
    # Instalar dependencias
    print_info "Instalando dependencias de CDK..."
    pip install -r requirements.txt --quiet
    
    print_success "Entorno Python configurado"
    echo ""
    
    cd "$ORIGINAL_DIR"
}

# Bootstrap CDK (solo primera vez)
bootstrap_cdk() {
    print_step "Verificando bootstrap de CDK..."
    echo ""
    
    cd "$CDK_DIR"
    source venv/bin/activate
    
    local account_id=$(aws sts get-caller-identity --query Account --output text)
    
    # Verificar si ya está bootstrapped
    if aws cloudformation describe-stacks --stack-name CDKToolkit --region $REGION &> /dev/null; then
        print_success "CDK ya está bootstrapped en $REGION"
    else
        print_info "Ejecutando bootstrap de CDK..."
        print_warning "Esto puede tomar 2-3 minutos..."
        
        if cdk bootstrap "aws://$account_id/$REGION"; then
            print_success "CDK bootstrapped exitosamente"
        else
            print_error "Error en bootstrap de CDK"
            cd "$ORIGINAL_DIR"
            exit 1
        fi
    fi
    
    echo ""
    cd "$ORIGINAL_DIR"
}

# Verificar si el stack ya existe
check_existing_stack() {
    print_info "Verificando si el stack ya existe..."
    
    if aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION &> /dev/null; then
        print_warning "Stack '$STACK_NAME' ya existe"
        echo ""
        read -p "¿Deseas actualizar el stack existente? (y/n) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Despliegue cancelado por el usuario"
            exit 0
        fi
    fi
}

# Sintetizar stack
synth_stack() {
    print_step "Sintetizando stack de CDK..."
    echo ""
    
    cd "$CDK_DIR"
    source venv/bin/activate
    
    print_info "Generando plantilla de CloudFormation..."
    if cdk synth > /dev/null; then
        print_success "Stack sintetizado exitosamente"
        
        # Mostrar recursos que se crearán
        print_info "Recursos que se crearán:"
        cdk synth | grep "Type: AWS::" | sort | uniq | sed 's/^/   - /'
    else
        print_error "Error al sintetizar stack"
        cd "$ORIGINAL_DIR"
        exit 1
    fi
    
    echo ""
    cd "$ORIGINAL_DIR"
}

# Desplegar stack
deploy_stack() {
    print_step "Desplegando stack: $STACK_NAME"
    echo ""
    
    cd "$CDK_DIR"
    source venv/bin/activate
    
    print_warning "Esto puede tomar 5-10 minutos..."
    print_info "Creando recursos en AWS..."
    echo ""
    
    # Desplegar con confirmación automática
    if cdk deploy --require-approval never --progress events; then
        print_success "Stack desplegado exitosamente"
    else
        print_error "Error en el despliegue"
        cd "$ORIGINAL_DIR"
        exit 1
    fi
    
    echo ""
    cd "$ORIGINAL_DIR"
}

# Obtener y mostrar outputs
show_outputs() {
    print_step "Obteniendo información del despliegue..."
    echo ""
    
    print_info "Outputs del stack:"
    echo ""
    
    aws cloudformation describe-stacks \
        --stack-name $STACK_NAME \
        --region $REGION \
        --query 'Stacks[0].Outputs' \
        --output table
    
    echo ""
    
    # Guardar outputs en variables para mostrar de forma más amigable
    local website_url=$(aws cloudformation describe-stacks \
        --stack-name $STACK_NAME \
        --region $REGION \
        --query 'Stacks[0].Outputs[?OutputKey==`WebsiteURL`].OutputValue' \
        --output text)
    
    local bucket_name=$(aws cloudformation describe-stacks \
        --stack-name $STACK_NAME \
        --region $REGION \
        --query 'Stacks[0].Outputs[?OutputKey==`S3BucketName`].OutputValue' \
        --output text)
    
    local distribution_id=$(aws cloudformation describe-stacks \
        --stack-name $STACK_NAME \
        --region $REGION \
        --query 'Stacks[0].Outputs[?OutputKey==`DistributionId`].OutputValue' \
        --output text)
    
    echo "=================================================="
    echo "📊 RESUMEN DEL DESPLIEGUE"
    echo "=================================================="
    echo ""
    print_success "Infraestructura desplegada exitosamente"
    echo ""
    echo "🌐 URLs importantes:"
    echo "   Website:      $website_url"
    echo "   S3 Bucket:    s3://$bucket_name"
    echo "   Distribution: $distribution_id"
    echo ""
    echo "📦 Recursos creados:"
    echo "   S3 Bucket (privado):     $bucket_name"
    echo "   CloudFront Distribution: $distribution_id"
    echo "   Origin Access Identity:  Acceso seguro S3 → CloudFront"
    echo ""
}

# Mostrar próximos pasos
show_next_steps() {
    local website_url=$(aws cloudformation describe-stacks \
        --stack-name $STACK_NAME \
        --region $REGION \
        --query 'Stacks[0].Outputs[?OutputKey==`WebsiteURL`].OutputValue' \
        --output text)
    
    echo "📋 PRÓXIMOS PASOS"
    echo "=================================================="
    echo ""
    echo "1️⃣  Verificar despliegue:"
    echo "   open $website_url"
    echo ""
    echo "2️⃣  Para actualizar contenido:"
    echo "   # Editar archivos en src/"
    echo "   vim src/index.html"
    echo "   # Sincronizar cambios"
    echo "   ./scripts/sync-and-deploy.sh"
    echo ""
    echo "3️⃣  Para análisis de código:"
    echo "   ./scripts/setup-sonarqube.sh"
    echo ""
    echo "=================================================="
    echo ""
}

# Mostrar información de costos
show_cost_info() {
    print_info "💰 Información de costos estimados:"
    echo ""
    echo "   S3:          ~\$0.02/GB/mes"
    echo "   CloudFront:  1TB gratis/mes (Free Tier)"
    echo "   CodeCommit:  5 usuarios gratis"
    echo "   CodeBuild:   100 minutos gratis/mes"
    echo ""
    echo "   📊 Total estimado para el taller: < \$1"
    echo "   (si se destruye después del taller)"
    echo ""
}

# Función para limpiar recursos
show_cleanup_info() {
    echo "🧹 LIMPIEZA DE RECURSOS"
    echo "=================================================="
    echo ""
    print_warning "Para eliminar todos los recursos después del taller:"
    echo ""
    echo "   cd $CDK_DIR && cdk destroy"
    echo ""
    echo "   O ejecutar:"
    echo "   aws cloudformation delete-stack --stack-name $STACK_NAME"
    echo ""
    print_info "Esto eliminará:"
    echo "   - S3 Bucket y contenido"
    echo "   - CloudFront Distribution"
    echo "   - CodeCommit Repository"
    echo "   - CodePipeline y CodeBuild"
    echo "   - Todos los recursos asociados"
    echo ""
}

# Función principal
main() {
    show_banner
    check_prerequisites
    setup_python_env
    bootstrap_cdk
    check_existing_stack
    synth_stack
    deploy_stack
    show_outputs
    show_next_steps
    show_cost_info
    show_cleanup_info
    
    print_success "🎉 Despliegue completado exitosamente!"
    echo ""
}

# Manejo de errores
error_handler() {
    print_error "Error en línea $1"
    cd "$ORIGINAL_DIR"
    exit 1
}

trap 'error_handler $LINENO' ERR
trap 'echo ""; print_warning "Script interrumpido por el usuario"; cd "$ORIGINAL_DIR"; exit 130' INT TERM

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
