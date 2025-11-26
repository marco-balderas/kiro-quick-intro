# Una introduccion rapida a Kiro

Kiro ofrece flexibilidad en cómo abordas el desarrollo de infraestructura en AWS, adaptándose a tu estilo de trabajo y las necesidades de cada proyecto. 

Puedes optar por Spec-Driven Design cuando tengas requisitos claros y prefieras un enfoque estructurado donde defines especificaciones primero y Kiro genera el código correspondiente. 

Si buscas mayor agilidad y exploración, Vibe Coding te permite desarrollar de forma conversacional e iterativa, describiendo lo que necesitas en lenguaje natural y refinando sobre la marcha. 

Para proyectos que requieren acompañamiento continuo, AI-DLC (AI-Driven Lifecycle) te asiste en todo el ciclo de vida del desarrollo, desde el diseño inicial hasta el deployment y mantenimiento. 

Estos enfoques no son excluyentes: puedes combinarlos según la fase del proyecto, permitiéndote prototipar rápidamente, estructurar cuando sea necesario, y evolucionar tu infraestructura con confianza.

---
## Comparativa de enfoques

| Característica | Spec Driven Development (SD) | Vibe Coding (VC) | AI-DLC (AI-Driven Life Cycle) |
| :--- | :--- | :--- | :--- |
| **Definición** | El desarrollo comienza y es guiado estrictamente por **especificaciones** detalladas y predefinidas (requisitos, diseño). | El desarrollo se guía por la **intuición**, la sensación del desarrollador ("la vibra"), y la necesidad inmediata, priorizando la entrega rápida. | Un ciclo de vida asistido o impulsado por **Inteligencia Artificial** que ayuda en las etapas de planificación, codificación, prueba y mantenimiento. |
| **Fase Inicial** | Énfasis en **documentación** y **planificación** exhaustiva antes de la codificación. | Énfasis en la **ejecución rápida**; la documentación es mínima o posterior. | La IA asiste en la **generación de especificaciones/historias** a partir de objetivos de alto nivel. |
| **Estructura/Arquitectura** | **Rígida** y predefinida; difícil de cambiar sin revisar las especificaciones. | **Orgánica** y **flexible**; puede ser inconsistente o mal escalada con el tiempo. | **Adaptativa**; la IA puede sugerir refactorizaciones o patrones arquitectónicos óptimos. |
| **Calidad y Testing** | La calidad se verifica mediante el cumplimiento de la **especificación** (pruebas unitarias y de aceptación claras). | La calidad se basa en la **funcionalidad percibida**; las pruebas pueden ser incompletas o apresuradas. | La IA ayuda a **generar pruebas unitarias y de integración** (código, casos de borde) para mejorar la cobertura. |
| **Velocidad de Desarrollo** | **Más lento** al principio debido a la planificación, pero más rápido y estable en fases posteriores. | **Muy rápido** al inicio (prototipado), pero puede ralentizarse drásticamente debido a la deuda técnica. | **Acelerado** a lo largo del ciclo gracias a la autocompletación, generación de código, y automatización de tareas. |
| **Deuda Técnica** | **Baja** si las especificaciones son buenas y se siguen. | **Alta** y acumulativa; el enfoque en la entrega rápida a menudo ignora la mantenibilidad. | **Reducida**; la IA puede identificar y corregir proactivamente patrones de código problemáticos (smells). |
| **Flexibilidad al Cambio** | **Baja**; los cambios significativos requieren un proceso formal de gestión del cambio. | **Alta**; los cambios se incorporan fácilmente, pero pueden desorganizar la base de código. | **Alta**; la IA puede evaluar el impacto de los cambios y ayudar a reescribir/adaptar el código rápidamente. |
| **Herramientas Clave** | Sistemas de gestión de requisitos (Jira, DOORS), DSLs para especificaciones. | IDEs, herramientas de desarrollo rápido, frameworks modernos. | **GitHub Copilot**, **Amazon Q**, **Kiro**, **Modelos de lenguaje (LLMs)** para generación de código/test. |
## Auditoría y Despliegue Automatizado - 90 minutos

[![SonarQube](https://img.shields.io/badge/SonarQube-MCP-blue)](http://localhost:9000)
[![Chrome DevTools](https://img.shields.io/badge/Chrome-DevTools-green)](https://developer.chrome.com/docs/devtools/)
[![AWS CDK](https://img.shields.io/badge/AWS-CDK-orange)](https://aws.amazon.com/cdk/)
[![TaskFlow Pro](https://img.shields.io/badge/TaskFlow-Pro-purple)]([https://github.com/kiro-workshop](https://github.com/marco-balderas/kiro-quick-intro))

**TaskFlow Pro** es una aplicación web ejecutiva de gestión de tareas que contiene **100+ problemas intencionados** para demostrar las capacidades de análisis e integración de MCP servers en Kiro.

---

## 🎯 Objetivo del Taller

Aprender a usar **Kiro** orquestando 3 MCP servers en un flujo integrado:

### 🔍 SonarQube MCP
- **27+ problemas de JavaScript** detectados
- Vulnerabilidades de seguridad (eval, credenciales hardcodeadas)
- Code smells y complejidad alta
- Análisis automático de calidad de código

### 🌐 Chrome Developer Tools MCP
- **40+ problemas de HTML** (accesibilidad, SEO)
- **37+ problemas de CSS** (performance, best practices)
- Métricas de Lighthouse (Performance, Accessibility, SEO)

### ☁️ AWS CDK MCP
- Infraestructura como código simplificada
- S3 + CloudFront con OAI (Origin Access Identity)
- Despliegue y sincronización automática
- Invalidación de caché

---

## 🚀 Quick Start

### Prerrequisitos

- **Docker** para SonarQube
- **AWS CLI** instalado para usos de Isengard CLI
- **Isengard CLI** para deplegar la app en cuenta de Isengard
- **AWS CDK** instalado (`npm install -g aws-cdk`)
- **Python 3.10+** (para CDK y servidor local)
- **Node.js 25.2.1+** (para CDK)


## 📁 Estructura del Proyecto

```
kiro-workshop/
├── src/                            # 🎨 Código fuente de TaskFlow Pro
│   ├── index.html                  # HTML con 47+ problemas intencionados
│   ├── app.js                      # JavaScript con 27+ problemas
│   ├── styles.css                  # CSS con 37+ problemas
│   └── package.json                # Dependencias con vulnerabilidades
│
├── scripts/                        # 🔧 Scripts de automatización
│   ├── setup-sonarqube.sh          # Setup SonarQube con captura de token
│   ├── deploy-aws.sh               # Despliegue AWS CDK simplificado
│   ├── sync-and-deploy.sh          # Sincronización y caché invalidation
│   └── run-sonar-analysis.sh       # Realiza un nuevo analisis
│
├── docs/                           # 📚 Documentación
│   ├── UI.png.                     # UI objetivo
│   └── FLUJO-SETUP-SONARQUBE.md    # Flujo de instacion de sonarqube para MCP server
│
├── cdk/                            # ☁️ Infraestructura AWS CDK
│   ├── app.py                      # Stack S3 + CloudFront + OAI
│   ├── requirements.txt            # Dependencias Python
│   └── cdk.json                    # Configuración CDK
│
├── docker-compose.yml              # 🐳 SonarQube containerizado
├── sonar-project.properties        # ⚙️ Configuración SonarQube
├── .cdkignore                      # 🚫 Exclusiones para CDK
└── README.md                       # 📖 Este archivo
```

---

## 🎨 Aplicación: TaskFlow Pro

### Características Principales

- **Tecnología**: HTML5, CSS3, JavaScript vanilla
- **Funcionalidad**: Gestión avanzada de tareas con prioridades
- **Arquitectura**: S3 + CloudFront con OAI (Origin Access Identity)
- **Problemas**: 100+ issues intencionados para análisis

### Funcionalidades

#### 🎨 Diseño
- **Header con gradiente** púrpura corporativo
- **Dashboard de estadísticas** (Total, Completadas, Pendientes)
- **Sistema de prioridades** (Low, Medium, High) con indicadores visuales
- **Filtros avanzados** (All, Active, Completed)
- **Animaciones suaves** y efectos hover
- **Responsive design** para mobile y desktop

#### 🎯 Componentes 
- **Task cards** con sombras y bordes de prioridad
- **Checkbox personalizado** con animaciones
- **Timestamps relativos** ("Just now", "5m ago")
- **Empty state** con mensaje amigable
- **Footer corporativo** con branding

---

## 🔧 MCP Servers Integrados

### 📝 Configuración MCP Servers

**Setup Automatizado**:
```bash
# Servir aplicación localmente 
cd src && python -m http.server 8000
```
Abrir una nueva terminal y ejecutar:

```bash
#Dar permisos de ejecucion
chmod +x scripts/*.sh

# Setup completo con captura interactiva de token
./scripts/setup-sonarqube.sh

# El script automáticamente:
# ✅ Inicia SonarQube con Docker
# ✅ Abre navegador para generar token
# ✅ Captura token interactivamente
# ✅ Guarda token permanentemente
# ✅ Crea proyecto automáticamente
# ✅ Ejecuta análisis (local o Docker)
```

```json
{
  "mcpServers": {
    "fetch": {
      "command": "uvx",
      "args": [
        "mcp-server-fetch"
      ],
      "env": {},
      "disabled": false,
      "autoApprove": []
    },
    "chrome-devtools": {
      "command": "npx",
      "args": [
        "chrome-devtools-mcp@latest"
      ],
      "disabled": false,
      "autoApprove": [
        "list_pages",
        "new_page",
        "take_snapshot",
        "performance_start_trace",
        "performance_analyze_insight",
        "performance_analyze_insight",
        "navigate_page",
        "take_screenshot",
        "evaluate_script"
      ]
    },
    "aws-knowledge-mcp-server": {
      "url": "https://knowledge-mcp.global.api.aws",
      "disabled": false
    },
    "awslabs.aws-documentation-mcp-server": {
      "command": "uvx",
      "args": [
        "awslabs.aws-documentation-mcp-server@latest"
      ],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR",
        "AWS_DOCUMENTATION_PARTITION": "aws",
        "MCP_USER_AGENT": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
      },
      "disabled": false,
      "autoApprove": []
    },
    "awslabs.cdk-mcp-server": {
      "command": "uvx",
      "args": [
        "awslabs.cdk-mcp-server@latest"
      ],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR"
      },
      "disabled": false,
      "autoApprove": [
        "CheckCDKNagSuppressions",
        "CDKGeneralGuidance",
        "ExplainCDKNagRule",
        "ExplainCDKNagRule",
        "ExplainCDKNagRule",
        "ExplainCDKNagRule",
        "ExplainCDKNagRule",
        "ExplainCDKNagRule",
        "ExplainCDKNagRule"
      ]
    },
    "sonarqube": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--name",
        "sonarqube-mcp-server",
        "--rm",
        "--network",
        "kiro-workshop_kiro-workshop",
        "-e",
        "SONARQUBE_TOKEN",
        "-e",
        "SONARQUBE_URL",
        "mcp/sonarqube"
      ],
      "env": {
        "SONARQUBE_TOKEN": "<PUT_YOUR_TOKEN_HERE>",
        "SONARQUBE_URL": "http://sonarqube:9000"
      },
      "disabled": false,
      "autoApprove": [
        "search_sonar_issues_in_projects",
        "get_component_measures",
        "get_project_quality_gate_status",
        "list_languages",
        "search_my_sonarqube_projects"
      ]
    }
  }
}
```
**Pegar su token obtenido en el MCP de sonarqube**

---

### 🎯 Ejemplos de Prompts para Kiro

#### Mejorar interfaz gráfica
```
Ayudame a mejorar la interfaz de usuario con el tool Chrome DevTools MCP en el sitio http://localhost:8000:
1. Logo: ayudame a agregarle un logo a la pagina utiliza #src/logo.png
2. Colores: ayudame a los colores de la seccion de Total Tasks, Completed y Pending tengan un buen contraste y que sean colores soludos en lugar de degradado, verificaque no se sobreescriban las reglas de CSS
3. Botones: Corrige el color del boton Agregar para que se vea el simbolo "+"
4. Interfaz de usuario: utiliza la imagen que te doy como referencia objetivo para que la inrfaz lusca igual
```

#### Análisis Completo
```
Ejecuta análisis completo de TaskFlow Pro utilizando los siguientes tools::
1. Tool sonarqube: analiza src/ y reporta top 5 problemas críticos
2. tool chrome-devtools: ejecuta Lighthouse en localhost:8000
3. awslabs-cdk-mcp-server: explique las implicaciones de seguridad de este código CDK utilizando la guía cdk-nag
4. Genera reporte consolidado con métricas y recomendaciones
```

#### Quality Gate Automático
```
Implementa quality gate:
1. Si SonarQube detecta bloqueadores, detén el flujo
2. Si Performance < 80, alerta pero continúa
3. Si Accessibility < 90, sugiere correcciones
4. Si todo pasa, confirma que está listo para producción
```


---

### ☁️ Infraestructura

**Arquitectura**:
```
src/ → S3 (Private) → CloudFront (Global CDN) → Users
     ↑                    ↑
Sync Script        Auto Cache Invalidation
```

**Despliegue Inicial**:
```bash
# Desplegar infraestructura (5 min)

# Autenticacion con Midway
mwinit

#Asumir role en cuenta de Isengard
isengardcli assume

#desplegar infraestructura
./scripts/deploy-aws.sh

# Recursos creados:
# ✅ S3 Bucket (privado con encriptación)
# ✅ CloudFront Distribution (CDN global)
# ✅ Origin Access Identity (acceso seguro)
# ✅ Deployment automático desde src/
```

**Actualización de Contenido**:
```bash
# Sincronizar cambios (2 min)
./scripts/sync-and-deploy.sh

# El script automáticamente:
# ✅ Sube archivos desde src/ a S3
# ✅ Elimina archivos obsoletos
# ✅ Invalida caché de CloudFront
# ✅ Configura cache-control headers
# ✅ Verifica despliegue
```

---

## 📚 Recursos y Documentación

### 🌐 Enlaces Importantes

#### Durante el Taller
- **SonarQube Dashboard**: http://localhost:9000/dashboard?id=kiro-workshop-task-manager
- **Aplicación Local**: http://localhost:8000

#### Recursos Externos
- [SonarQube Rules](https://rules.sonarsource.com/javascript/)
- [Chrome DevTools Documentation](https://developer.chrome.com/docs/devtools/)
- [Lighthouse Scoring](https://web.dev/performance-scoring/)
- [AWS CDK Documentation](https://docs.aws.amazon.com/cdk/)
- [Kiro MCP Documentation](https://kiro.dev/docs)

---

## 🧹 Limpieza de Recursos

### Eliminar Stack Completo

```bash
# Opción 1: Usando CDK
cd cdk
source venv/bin/activate
cdk destroy

# Opción 2: Usando AWS CLI
aws cloudformation delete-stack --stack-name KiroWorkshopTaskManager
```

### Recursos que se Eliminarán

- ✅ S3 Bucket y todo su contenido
- ✅ CloudFront Distribution
- ✅ Origin Access Identity
- ✅ Todos los recursos asociados

---
