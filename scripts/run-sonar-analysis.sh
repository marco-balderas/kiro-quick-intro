#!/bin/bash

# ============================================
# Run SonarQube Analysis Only
# Script ligero para ejecutar análisis
# ============================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

# Configuración
SONAR_HOST_URL="${SONAR_HOST_URL:-http://localhost:9000}"
SONAR_TOKEN="${SONAR_TOKEN:-}"
PROJECT_KEY="kiro-workshop-task-manager"
PROJECT_NAME="Task Manager - Kiro Workshop"

echo ""
print_info "Ejecutando análisis de SonarQube..."
echo ""

# Verificar token
if [ -z "$SONAR_TOKEN" ]; then
    print_error "SONAR_TOKEN no configurado"
    echo "Ejecuta: export SONAR_TOKEN='tu-token'"
    exit 1
fi

# Verificar SonarQube está corriendo
if ! curl -s "$SONAR_HOST_URL/api/system/status" | grep -q "UP"; then
    print_error "SonarQube no está accesible en $SONAR_HOST_URL"
    echo "Verifica que esté corriendo: docker ps | grep sonarqube"
    exit 1
fi

# Ejecutar análisis
if command -v sonar-scanner &> /dev/null; then
    # Usar sonar-scanner local
    print_info "Usando sonar-scanner local..."
    sonar-scanner \
        -Dsonar.projectKey=$PROJECT_KEY \
        -Dsonar.projectName="$PROJECT_NAME" \
        -Dsonar.sources=src \
        -Dsonar.exclusions="node_modules/**,cdk/**,*.md,.git/**,venv/**,backup-original/**,soluciones-referencia/**,scripts/**,docs/**" \
        -Dsonar.host.url=$SONAR_HOST_URL \
        -Dsonar.login=$SONAR_TOKEN
else
    # Usar Docker
    print_info "Usando sonar-scanner con Docker..."
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
fi

echo ""
print_success "Análisis completado"
echo ""
echo "📊 Ver resultados en:"
echo "   $SONAR_HOST_URL/dashboard?id=$PROJECT_KEY"
echo ""
