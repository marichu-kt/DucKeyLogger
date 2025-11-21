# :duck: DucKeyLogger — Keylogger usando un USB Rubber Ducky de Hack5 :keyboard: - Herramienta Educativa de Ciberseguridad :mortar_board::shield:

> [!WARNING]  
> **Aviso legal y ético**: Este proyecto está diseñado **exclusivamente** para fines educativos, de auditoría y de concienciación en ciberseguridad, en **entornos controlados**, de **laboratorio** y siempre con el **permiso explícito, previo y documentado** de todas las partes implicadas.  
>  
> El uso de keyloggers o técnicas similares en sistemas de terceros **sin autorización** puede constituir un **delito**, sancionable administrativa y/o penalmente según la legislación vigente en tu país.  
>  
> Al utilizar este material te comprometes a:  
> - Emplearlo **solo** en equipos y cuentas **propias** o en aquellos para los que dispongas de un **consentimiento explícito por escrito**.  
> - No utilizarlo para **espiar**, **robar credenciales**, **suplantar identidades** o causar cualquier tipo de **daño**.  
> - Respetar siempre las **leyes**, los **códigos de conducta profesionales** y los **principios éticos** de la ciberseguridad (responsible disclosure, mínima intrusión, protección de la privacidad, etc.).  

## 🧭 Descripción del proyecto
**DucKeyLogger** es una herramienta educativa de ciberseguridad que combina la capacidad de inyección USB del Rubber Ducky con un keylogger en PowerShell, capturando pulsaciones del teclado y enviándolas ofuscadas a un bot de Telegram para su posterior decodificación mediante scripts Python, sirviendo como demostración práctica de vectores de ataque y técnicas de exfiltración de datos en entornos controlados para fines educativos y de investigación en seguridad informática.

El repositorio incluye materiales y guía visual para **demostrar** (de forma controlada) cómo podrían aparecer registros de eventos en un canal de Telegram, así como el **proceso de exportación** de dichos mensajes para su análisis forense.

> [!CAUTION]
> Como autor de este proyecto **no me hago responsable** de cualquier uso indebido, ilegal o malintencionado que se haga del mismo.

## 🎯 Objetivos educativos
- Concienciar sobre los riesgos de registrar entradas de teclado y su envío a terceros.
- Explicar un **flujo de trabajo de auditoría**: desde la aparición de mensajes en Telegram hasta su **exportación** a **JSON** para su análisis.
- Reforzar **buenas prácticas defensivas** y controles de seguridad.

## 🔧 Requisitos mínimos (entorno de laboratorio seguro)
- Cuenta de Telegram y un bot creado con **@BotFather**.
- **Telegram Desktop** para exportar el chat.
- Un **USB Rubber Ducky**, por ejemplo el de Hack5 (se puede ejecutar manualmente, usando execute.bat).

## 🗂️ Exportar el chat a JSON (Telegram Desktop)
1. Abre Telegram Desktop y entra en el chat del bot.
2. Abre el menú **⋯** → **Export chat history** / **Exportar historial del chat**.
3. Elige **Machine‑readable JSON** como formato de exportación.
4. Confirma y espera el mensaje de **éxito**. Obtendrás un archivo `.json` para su análisis.

Las capturas siguientes ilustran el proceso.

## 📸 Guía visual

### Interacción en Telegram (dos imágenes en una sola fila)
<!-- Dos imágenes en la misma fila -->
<table>
  <tr>
    <td width="50%">
      <img src="images/DucKeyLogger-1.jpg" alt="Mensaje de inicio de Telegram" width="100%"/>
      <p align="center"><em>Mensaje de inicio de Telegram</em></p>
    </td>
    <td width="50%">
      <img src="images/DucKeyLogger-2.jpg" alt="Ejemplos del chat con logs censurados" width="100%"/>
      <p align="center"><em>Ejemplos del chat con los logs del keylogger (censurados)</em></p>
    </td>
  </tr>
</table>

### Exportación del chat a JSON (tres imágenes en la misma fila)
<!-- Tres imágenes en la misma fila -->
<table>
  <tr>
    <td width="33%">
      <img src="images/TelegramDesktop-1.png" alt="Paso 1: abrir exportación del chat" width="100%"/>
      <p align="center"><em>Paso 1 – Abrir exportación</em></p>
    </td>
    <td width="33%">
      <img src="images/TelegramDesktop-2.png" alt="Paso 2: elegir formato JSON" width="100%"/>
      <p align="center"><em>Paso 2 – Elegir JSON</em></p>
    </td>
    <td width="33%">
      <img src="images/TelegramDesktop-3.png" alt="Paso 3: exportación completada" width="100%"/>
      <p align="center"><em>Paso 3 – Éxito de exportación</em></p>
    </td>
  </tr>
</table>


## 🔎 Ejemplo: decodificar con el traductor (`decoder-B64`)

En la misma carpeta que este `README.md` hay un directorio llamado `decoder-B64/` con un traductor/decodificador en Python para procesar el JSON exportado de Telegram y producir un texto legible.

**Estructura esperada:**
```
DucKeyLogger/
├── 🧩 Ducky Encoder.html       # Utilidad local para codificar scripts Ducky (inject.bin)
├── ⚡ execute.bat              # Lanzador/automatización en Windows manual (si no tenemos USB Rubber Ducky)
├── 🦆 inject.bin               # Payload compilado para la SD del USB Rubber Ducky
├── 🛡️ keylogger.ps1            # PoC educativa de registro de pulsaciones (keylogger)
├── 📝 README.md                # Descripción y notas del proyecto
└── 📂 decoder-B64/             # Traductor de Base64 a texto humano legible
    ├── 🐍 decoder.py           # Script de decodificación Base64
    ├── 📥 entrada.json         # Archivo JSON al exportar el chat del Bot de telegram
    └── 📤 salida.txt           # Salida generada por el traductor (decoder.py) en lenguaje humano
```

**Pasos:**  
1) Exporta la conversación desde **Telegram Desktop** en formato **Machine-readable JSON** (ver sección de capturas).  
2) Copia el archivo exportado como `decoder-B64/entrada.json`.  
3) Ejecuta el traductor para generar `decoder-B64/salida.txt`.

**Comandos de ejemplo:**

Windows (PowerShell):
```powershell
cd decoder-B64
python .\decoder.py -i .\entrada.json -o .\salida.txt
```

Windows (CMD):
```
cd decoder-B64
python decoder.py -i entrada.json -o salida.txt
```

Linux / macOS:
```bash
cd decoder-B64
python3 decoder.py -i entrada.json -o salida.txt
```

> Si tu `decoder.py` admite entrada/salida por **STDIN/STDOUT**, también puedes usar:
```bash
cd decoder-B64
python3 decoder.py entrada.json > salida.txt
```

**Resultado esperado (`salida.txt`):**
```
DucKeyLogger ACTIVADO - 11/18/2025 16:57:46
CAMBIO DE APLICACIÓN: Outlook - Bandeja de entrada -> Bloc de notas - notas.txt
NUEVA VENTANA: Bloc de notas - notas.txt - notas.txt
[VS Code] escribiendo: "mensaje: revisa el mail, porfa"[ENTER]
CAMBIO DE APLICACIÓN: GitHub - Pull Requests -> Visual Studio Code
NUEVA VENTANA: Visual Studio Code - Edge
NUEVA VENTANA: Login - outlook.com - Brave
[mail.proton.me - Brave] username: marichu.private@proton.me
[mail.proton.me - Brave] password: Pa$$w0rd-XYZ
[mail.proton.me - Brave] Iniciar sesión [CLICK]
LOGIN: mail.proton.me | usuario=marichu.private@proton.me | resultado=success
NUEVA VENTANA: Login - github.com - Chrome
[github.com - Chrome] username: marichu@gmail.com
[github.com - Chrome] password: S3gura!2025
[github.com - Chrome] Iniciar sesión [CLICK]
LOGIN: github.com | usuario=marichu@gmail.com | resultado=success
CAMBIO DE APLICACIÓN: Visual Studio Code -> Explorador de archivos
NUEVA VENTANA: Explorador de archivos - Edge
NUEVA VENTANA: Nueva pestaña - Edge
[DuckDuckGo - Edge] tutorial receta tortilla de patata [ENTER]
NUEVA VENTANA: tutorial receta tortilla de patata - Buscar con DuckDuckGo - Edge
NUEVA VENTANA: Login - github.com - Edge
```
Este fichero contiene los textos **ya decodificados** (por ejemplo, cadenas que venían en Base64 en el JSON). Empléalo únicamente con **datos simulados** y en **entornos controlados**.


## 🛡️ Buenas prácticas y mitigación
- Minimiza privilegios, aplica **EDR/antivirus** y listas de permitidos.
- Emplea **protecciones de entrada**, bloqueo de macros, políticas de ejecución y **control de dispositivos**.
- Monitoriza **telemetría** y **IOC** asociados a exfiltración por mensajería.
- Formación y **concienciación** del usuario final.

## 📜 Licencia
Uso educativo. Verifica restricciones legales de tu país/organización antes de usar cualquier material de este repositorio.
