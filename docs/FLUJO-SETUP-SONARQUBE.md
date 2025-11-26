# Flujo Completo - setup-sonarqube.sh

## 🔄 Diagrama de Flujo Interactivo

```
┌─────────────────────────────────────────────────────────────┐
│                  INICIO: ./setup-sonarqube.sh               │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
            ┌─────────────────┐
            │ Verificar Docker│
            └────────┬────────┘
                     │
                     ▼
              ┌──────────┐
              │ ¿Existe? │
              └─┬──────┬─┘
                │ No   │ Sí
                ▼      │
         ┌──────────┐  │
         │  ERROR   │  │
         │  EXIT    │  │
         └──────────┘  │
                       ▼
            ┌──────────────────┐
            │ ¿SonarQube está  │
            │   ejecutándose?  │
            └─┬──────────────┬─┘
              │ No           │ Sí
              ▼              │
    ┌──────────────────┐    │
    │ docker-compose   │    │
    │     up -d        │    │
    └────────┬─────────┘    │
             │              │
             └──────┬───────┘
                    ▼
         ┌─────────────────────┐
         │ Esperar hasta 3 min │
         │  (verificar status) │
         └──────────┬──────────┘
                    │
                    ▼
              ┌──────────┐
              │ ¿Listo?  │
              └─┬──────┬─┘
                │ No   │ Sí
                ▼      │
         ┌──────────┐  │
         │  ERROR   │  │
         │  EXIT    │  │
         └──────────┘  │
                       ▼
            ┌──────────────────┐
            │ ¿Token existe en │
            │  $SONAR_TOKEN?   │
            └─┬──────────────┬─┘
              │ No           │ Sí
              ▼              │
    ┌──────────────────┐    │
    │ ¿Ingresar token? │    │
    └─┬──────────────┬─┘    │
      │ Sí           │ No   │
      ▼              │      │
┌─────────────────┐  │      │
│ Abrir navegador │  │      │
│ Mostrar pasos   │  │      │
│ Capturar token  │  │      │
└────────┬────────┘  │      │
         │            │      │
         ▼            │      │
   ┌──────────┐      │      │
   │ ¿Guardar │      │      │
   │permanente│      │      │
   └─┬──────┬─┘      │      │
     │ Sí   │ No     │      │
     ▼      │        │      │
┌─────────┐ │        │      │
│Guardar  │ │        │      │
│en shell │ │        │      │
│profile  │ │        │      │
└────┬────┘ │        │      │
     │      │        │      │
     └──┬───┘        │      │
        │            │      │
        └────┬───────┘      │
             │              │
             └──────┬───────┘
                    ▼
            ┌──────────────┐
            │ Validar Token│
            └─┬──────────┬─┘
              │ Inválido │ Válido
              ▼          │
    ┌──────────────────┐ │
    │ ¿Reintentar con  │ │
    │  nuevo token?    │ │
    └─┬──────────────┬─┘ │
      │ Sí           │No │
      ▼              │   │
  [Volver a         │   │
   capturar]        │   │
                    ▼   │
             ┌──────────┐│
             │  ERROR   ││
             │  EXIT    ││
             └──────────┘│
                         │
                         ▼
              ┌──────────────────┐
              │ ¿Proyecto existe │
              │  en SonarQube?   │
              └─┬──────────────┬─┘
                │ No           │ Sí
                ▼              │
      ┌──────────────────┐    │
      │ Crear proyecto   │    │
      │  usando API      │    │
      └────────┬─────────┘    │
               │              │
               ▼              │
         ┌──────────┐         │
         │ ¿Éxito?  │         │
         └─┬──────┬─┘         │
           │ No   │ Sí        │
           ▼      │           │
    ┌──────────┐  │           │
    │ Mostrar  │  │           │
    │ pasos    │  │           │
    │ manuales │  │           │
    └──────────┘  │           │
                  │           │
                  └─────┬─────┘
                        │
                        ▼
              ┌──────────────────┐
              │ ¿sonar-scanner   │
              │   instalado?     │
              └─┬──────────────┬─┘
                │ No           │ Sí
                ▼              │
      ┌──────────────────┐    │
      │ Usar Docker para │    │
      │ ejecutar análisis│    │
      └────────┬─────────┘    │
               │              │
               └──────┬───────┘
                      ▼
            ┌──────────────────┐
            │ Ejecutar análisis│
            │   de SonarQube   │
            └────────┬─────────┘
                     │
                     ▼
              ┌──────────┐
              │ ¿Éxito?  │
              └─┬──────┬─┘
                │ No   │ Sí
                ▼      │
         ┌──────────┐  │
         │ Mostrar  │  │
         │troublesh.│  │
         │  EXIT    │  │
         └──────────┘  │
                       ▼
            ┌──────────────────┐
            │ Mostrar resumen  │
            │  - Issues: 27+   │
            │  - URLs          │
            │  - Próximos pasos│
            └────────┬─────────┘
                     │
                     ▼
            ┌─────────────────┐
            │  FIN EXITOSO    │
            └─────────────────┘
```

---

## 📊 Puntos de Decisión Clave

### 1. Token No Configurado

**Opciones:**
- ✅ **Ingresar ahora** (Recomendado)
  - Abre navegador automáticamente
  - Guía paso a paso
  - Opción de guardar permanentemente
  
- ⚠️ **Continuar sin token**
  - Funcionalidad limitada
  - No puede crear proyecto
  - No puede ejecutar análisis completo

### 2. Token Inválido

**Opciones:**
- ✅ **Ingresar nuevo token**
  - Permite corregir el error
  - Valida inmediatamente
  
- ❌ **Salir**
  - Termina el script
  - Usuario debe configurar manualmente

### 3. Proyecto No Existe

**Acciones:**
- ✅ **Con token**: Crea automáticamente
- ⚠️ **Sin token**: Muestra instrucciones manuales

### 4. sonar-scanner No Instalado

**Acciones:**
- ✅ **Usa Docker automáticamente**
- No requiere instalación local
- Se conecta a la red de SonarQube

---

## 🎯 Escenarios de Usuario

### Escenario A: Usuario Nuevo (Primera Vez)

```bash
# Usuario ejecuta sin configuración previa
./setup-sonarqube.sh
```

**Flujo:**
1. ✅ Verifica Docker
2. ✅ Inicia SonarQube
3. ⚠️ No tiene token → **Solicita ingresar**
4. 🌐 Abre navegador
5. 📝 Usuario genera token en SonarQube
6. ⌨️ Usuario pega token
7. 💾 Ofrece guardar permanentemente
8. ✅ Valida token
9. ✅ Crea proyecto automáticamente
10. ✅ Ejecuta análisis con Docker
11. 📊 Muestra resultados

**Tiempo estimado:** 5-7 minutos (incluye generación de token)

### Escenario B: Usuario Experimentado (Token Guardado)

```bash
# Usuario ya tiene token en .zshrc
./setup-sonarqube.sh
```

**Flujo:**
1. ✅ Verifica Docker
2. ✅ SonarQube ya está corriendo
3. ✅ Token encontrado y válido
4. ✅ Proyecto ya existe
5. ✅ Ejecuta análisis
6. 📊 Muestra resultados

**Tiempo estimado:** 2-3 minutos

### Escenario C: Usuario con Token Expirado

```bash
# Token existe pero está expirado
./setup-sonarqube.sh
```

**Flujo:**
1. ✅ Verifica Docker
2. ✅ SonarQube corriendo
3. ⚠️ Token inválido → **Solicita nuevo**
4. 🌐 Abre navegador
5. ⌨️ Usuario ingresa nuevo token
6. 💾 Actualiza en shell profile
7. ✅ Valida nuevo token
8. ✅ Continúa con análisis

**Tiempo estimado:** 4-5 minutos

### Escenario D: Usuario Sin Token (Modo Limitado)

```bash
# Usuario decide no ingresar token
./setup-sonarqube.sh
```

**Flujo:**
1. ✅ Verifica Docker
2. ✅ SonarQube corriendo
3. ⚠️ Sin token → Usuario rechaza ingresar
4. ⚠️ No puede crear proyecto
5. ⚠️ Muestra instrucciones manuales
6. ❌ Sale del script

**Tiempo estimado:** 1 minuto

---

## 💡 Mejores Prácticas

### Para Instructores

1. **Pre-configurar tokens**
   ```bash
   # Antes del taller, configurar token
   export SONAR_TOKEN="token-del-instructor"
   echo 'export SONAR_TOKEN="token-del-instructor"' >> ~/.zshrc
   ```

2. **Tener tokens de respaldo**
   - Generar múltiples tokens en SonarQube
   - Compartir con asistentes del taller
   - Tener plan B si un token falla

3. **Demostrar el flujo completo**
   - Mostrar generación de token en vivo
   - Explicar por qué es necesario
   - Mostrar cómo guardarlo permanentemente

### Para Participantes

1. **Guardar el token**
   - Siempre elegir "Sí" cuando se ofrece guardar
   - Facilita ejecuciones futuras
   - Evita tener que regenerar

2. **Verificar el token**
   ```bash
   # Verificar que el token esté guardado
   echo $SONAR_TOKEN
   
   # Si está vacío, cargar el perfil
   source ~/.zshrc  # o ~/.bashrc
   ```

3. **Regenerar si es necesario**
   - Si el token expira, el script lo detecta
   - Seguir las instrucciones para generar uno nuevo
   - El script guía todo el proceso

---

## 🔧 Personalización

### Cambiar Tiempo de Expiración del Token

En SonarQube al generar el token:
- **30 días**: Para talleres y desarrollo
- **90 días**: Para uso regular
- **No expira**: Solo para ambientes de prueba

### Cambiar Ubicación de Guardado

Editar la función `prompt_for_token()`:
```bash
# Personalizar archivo de perfil
shell_profile="$HOME/.mi_perfil_custom"
```

### Deshabilitar Apertura Automática del Navegador

Comentar estas líneas en `prompt_for_token()`:
```bash
# if command -v open &> /dev/null; then
#     open "$SONAR_HOST_URL" 2>/dev/null || true
# fi
```

---

## 📈 Métricas de Éxito

### Indicadores de Flujo Exitoso

- ✅ Token capturado y validado
- ✅ Proyecto creado automáticamente
- ✅ Análisis completado sin errores
- ✅ 27+ issues detectados
- ✅ Dashboard accesible

### Tiempo Promedio por Escenario

| Escenario | Primera Vez | Subsecuente |
|-----------|-------------|-------------|
| Con token guardado | 5-7 min | 2-3 min |
| Sin token (captura) | 5-7 min | 5-7 min |
| Token expirado | 4-5 min | 4-5 min |
| Sin token (rechaza) | 1 min | 1 min |

---

## 🆘 Troubleshooting del Flujo

### Problema: Navegador no abre automáticamente

**Solución:**
```bash
# Abrir manualmente
open http://localhost:9000  # macOS
xdg-open http://localhost:9000  # Linux
```

### Problema: Token no se guarda

**Solución:**
```bash
# Guardar manualmente
echo 'export SONAR_TOKEN="tu-token"' >> ~/.zshrc
source ~/.zshrc
```

### Problema: Token inválido después de guardarlo

**Solución:**
```bash
# Limpiar token viejo
unset SONAR_TOKEN

# Ejecutar script nuevamente
./setup-sonarqube.sh
# Ingresar nuevo token cuando se solicite
```

---

**¡Flujo completamente automatizado e interactivo! 🚀**
