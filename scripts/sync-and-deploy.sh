#!/bin/bash
# ============================================
# Script de Sincronización y Despliegue
# Taller Kiro - Versión Simplificada
# ============================================
set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Variables
STACK_NAME="KiroWorkshopTaskManager"
REGION="${AWS_REGION:-us-east-1}"
CDK_DIR="cdk"
SRC_DIR="src"

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
    echo "==================================================="
    echo "🚀 SYNC & DEPLOY - TASKFLOW PRO"
    echo "==================================================="
    echo ""
    echo "Stack:  $STACK_NAME"
    echo "Region: $REGION"
    echo "Source: $SRC_DIR/"
    echo ""
}

# Verificar si el stack existe
check_stack_exists() {
    print_info "Verificando si el stack existe..."
    if aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION &> /dev/null; then
        print_success "Stack '$STACK_NAME' encontrado"
        return 0
    else
        print_warning "Stack '$STACK_NAME' no existe"
        return 1
    fi
}

# Obtener información del stack
get_stack_info() {
    print_info "Obteniendo información del stack..."
    
    # Obtener outputs del stack
    BUCKET_NAME=$(aws cloudformation describe-stacks \
        --stack-name $STACK_NAME \
        --region $REGION \
        --query 'Stacks[0].Outputs[?OutputKey==`S3BucketName`].OutputValue' \
        --output text)
    
    DISTRIBUTION_ID=$(aws cloudformation describe-stacks \
        --stack-name $STACK_NAME \
        --region $REGION \
        --query 'Stacks[0].Outputs[?OutputKey==`DistributionId`].OutputValue' \
        --output text)
    
    WEBSITE_URL=$(aws cloudformation describe-stacks \
        --stack-name $STACK_NAME \
        --region $REGION \
        --query 'Stacks[0].Outputs[?OutputKey==`WebsiteURL`].OutputValue' \
        --output text)
    
    if [ -z "$BUCKET_NAME" ] || [ -z "$DISTRIBUTION_ID" ]; then
        print_error "No se pudieron obtener los outputs del stack"
        exit 1
    fi
    
    print_success "Información del stack obtenida"
    echo "   Bucket: $BUCKET_NAME"
    echo "   Distribution: $DISTRIBUTION_ID"
    echo "   Website: $WEBSITE_URL"
    echo ""
}

# Sincronizar archivos con S3
sync_to_s3() {
    print_step "Sincronizando archivos con S3..."
    echo ""
    
    if [ ! -d "$SRC_DIR" ]; then
        print_error "Directorio $SRC_DIR no encontrado"
        exit 1
    fi
    
    print_info "Subiendo archivos desde $SRC_DIR/ a s3://$BUCKET_NAME/"
    
    # Sincronizar archivos
    aws s3 sync "$SRC_DIR/" "s3://$BUCKET_NAME/" \
        --delete \
        --exclude "node_modules/*" \
        --exclude "*.md" \
        --cache-control "public, max-age=31536000" \
        --metadata-directive REPLACE
    
    # Configurar cache-control específico para HTML
    aws s3 cp "s3://$BUCKET_NAME/index.html" "s3://$BUCKET_NAME/index.html" \
        --metadata-directive REPLACE \
        --cache-control "public, max-age=0, must-revalidate" \
        --content-type "text/html"
    
    print_success "Archivos sincronizados exitosamente"
    echo ""
}

# Invalidar caché de CloudFront
invalidate_cloudfront() {
    print_step "Invalidando caché de CloudFront..."
    echo ""
    
    print_info "Creando invalidación para distribución $DISTRIBUTION_ID"
    
    # Crear invalidación
    INVALIDATION_ID=$(aws cloudfront create-invalidation \
        --distribution-id $DISTRIBUTION_ID \
        --paths "/*" \
        --query 'Invalidation.Id' \
        --output text)
    
    print_success "Invalidación creada: $INVALIDATION_ID"
    
    # Esperar a que complete (opcional)
    read -p "¿Deseas esperar a que complete la invalidación? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Esperando a que complete la invalidación..."
        aws cloudfront wait invalidation-completed \
            --distribution-id $DISTRIBUTION_ID \
            --id $INVALIDATION_ID
        print_success "Invalidación completada"
    else
        print_info "Invalidación en progreso (toma 1-5 minutos)"
    fi
    
    echo ""
}

# Verificar despliegue
verify_deployment() {
    print_step "Verificando despliegue..."
    echo ""
    
    print_info "Probando conectividad..."
    
    # Probar con curl
    if curl -s -I "$WEBSITE_URL" | grep -q "200 OK"; then
        print_success "Sitio web accesible"
    else
        print_warning "Sitio web no responde (puede tomar unos minutos)"
    fi
    
    echo ""
}

# Mostrar resumen
show_summary() {
    echo "==================================================="
    echo "📊 RESUMEN DEL DESPLIEGUE"
    echo "==================================================="
    echo ""
    print_success "Sincronización completada exitosamente"
    echo ""
    echo "🌐 URLs importantes:"
    echo "   Website:      $WEBSITE_URL"
    echo "   S3 Bucket:    s3://$BUCKET_NAME"
    echo "   Distribution: $DISTRIBUTION_ID"
    echo ""
    echo "📋 Próximos pasos:"
    echo "   1. Abrir: $WEBSITE_URL"
    echo "   2. Verificar que los cambios se reflejen"
    echo "   3. Si no se ven cambios, esperar 1-2 minutos"
    echo ""
    echo "🔄 Para futuras actualizaciones:"
    echo "   ./scripts/sync-and-deploy.sh"
    echo ""
}

# Función principal
main() {
    show_banner
    
    # Verificar que el stack existe
    if ! check_stack_exists; then
        print_error "Primero debes desplegar la infraestructura:"
        echo "   ./scripts/deploy-aws.sh"
        exit 1
    fi
    
    # Obtener información del stack
    get_stack_info
    
    # Sincronizar archivos
    sync_to_s3
    
    # Invalidar caché
    invalidate_cloudfront
    
    # Verificar despliegue
    verify_deployment
    
    # Mostrar resumen
    show_summary
}

# Manejo de errores
error_handler() {
    print_error "Error en línea $1"
    exit 1
}

trap 'error_handler $LINENO' ERR
trap 'echo ""; print_warning "Script interrumpido por el usuario"; exit 130' INT TERM

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
