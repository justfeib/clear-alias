@echo off
setlocal EnableExtensions

rem ============================================================
rem  clear-alias.bat
rem
rem  Rende disponibile il comando "clear" in cmd.exe.
rem
rem  Come: crea un piccolissimo shim "clear.cmd" (contenuto:
rem  "cls") dentro %LOCALAPPDATA%\Microsoft\WindowsApps, che e'
rem  gia' nel PATH dell'utente per impostazione predefinita.
rem
rem  Cosa NON fa: niente registro, niente AutoRun, niente setx,
rem  nessuna modifica al PATH, nessun privilegio di amministratore.
rem  Per disfare tutto basta cancellare quel singolo file (oppure
rem  usare /uninstall).
rem
rem  Uso:
rem    clear-alias.bat              installa (o ripara)
rem    clear-alias.bat /uninstall   rimuove
rem    clear-alias.bat /?           questo aiuto
rem ============================================================

set "ACTION=install"

if "%~1"=="" goto :start
if /i "%~1"=="/?" goto :usage
if /i "%~1"=="-h" goto :usage
if /i "%~1"=="/help" goto :usage
if /i "%~1"=="/uninstall" (
    set "ACTION=uninstall"
    goto :start
)
if /i "%~1"=="-u" (
    set "ACTION=uninstall"
    goto :start
)
echo [ERRORE] Opzione non riconosciuta: %~1
echo          Usa "%~nx0 /?" per l'aiuto.
exit /b 2

:start
set "SHIM=clear.cmd"
set "TARGET=%LOCALAPPDATA%\Microsoft\WindowsApps"

if /i "%ACTION%"=="uninstall" goto :uninstall
goto :install

rem ------------------------------------------------------------
:install
call :checkdir "%TARGET%"
if errorlevel 1 goto :notarget

set "PREEXISTING="
if exist "%TARGET%\%SHIM%" set "PREEXISTING=1"

rem Scrive lo shim: due righe, fine a capo Windows (CRLF).
(echo @echo off&echo cls)>"%TARGET%\%SHIM%" 2>nul
if not exist "%TARGET%\%SHIM%" goto :writefail

echo.
if defined PREEXISTING (
    echo [OK] Lo shim esisteva gia' ed e' stato riscritto:
) else (
    echo [OK] Creato lo shim:
)
echo      %TARGET%\%SHIM%
echo.
echo      Contenuto:
echo        @echo off
echo        cls
echo.

call :whereclear
call :psstatus

echo.
echo Fatto. Apri un cmd e scrivi "clear": deve pulire lo schermo
echo come "cls". Non serve riavviare nulla: la cartella era gia'
echo nel PATH, quindi funziona anche nei cmd gia' aperti.
echo.
echo Per rimuovere: "%~nx0 /uninstall"
exit /b 0

rem ------------------------------------------------------------
:uninstall
if not exist "%TARGET%\%SHIM%" (
    echo.
    echo [INFO] Niente da rimuovere: %TARGET%\%SHIM% non esiste.
    exit /b 0
)
del /q "%TARGET%\%SHIM%" 2>nul
if exist "%TARGET%\%SHIM%" (
    echo.
    echo [ERRORE] Impossibile cancellare %TARGET%\%SHIM%
    echo          Chiudi eventuali cmd aperti e riprova.
    exit /b 1
)
echo.
echo [OK] Rimosso: %TARGET%\%SHIM%
echo.
call :whereclear
echo.
echo Nota: "cls" in cmd e "clear" in PowerShell non sono stati
echo toccati e continuano a funzionare.
exit /b 0

rem ------------------------------------------------------------
:notarget
echo.
echo [ERRORE] Cartella non disponibile o non scrivibile:
echo          %TARGET%
echo.
echo          Puo' succedere se la cartella e' stata rimossa o se
echo          l'utente non ha i permessi di scrittura.
echo          In quel caso: crea una cartella qualsiasi, mettila
echo          nel PATH utente, e copiaci dentro un file
echo          %SHIM% contenente le due righe qui sopra.
echo          Non aggiungo io il PATH per non modificare la tua
echo          configurazione senza che tu lo veda.
exit /b 1

rem ------------------------------------------------------------
:writefail
echo.
echo [ERRORE] Scrittura fallita su:
echo          %TARGET%\%SHIM%
exit /b 1

rem ------------------------------------------------------------
rem  Sotto-routine: la cartella esiste ed e' scrivibile?
:checkdir
set "PROBE=%~1\.__clear_alias_probe.tmp"
if not exist "%~1\" exit /b 1
2>nul>"%PROBE%" echo probe
if not exist "%PROBE%" exit /b 1
del /q "%PROBE%" >nul 2>&1
exit /b 0

rem  Sotto-routine: dove risolve "clear" adesso?
:whereclear
echo Verifica - dove risolve "clear" in questo momento:
where clear 2>nul
if errorlevel 1 (
    echo   [ATTENZIONE] "clear" non viene trovato nel PATH.
    echo                Controlla che %TARGET% sia nel PATH utente.
) else (
    echo   [OK] Trovato. Se sopra compaiono piu' righe, in cmd
    echo        vince la PRIMA: se non e' lo shim, un altro comando
    echo        clear, per esempio un clear.exe, lo precede nel PATH.
)
exit /b 0

rem  Sotto-routine: PowerShell ce l'ha gia' o no?
:psstatus
where powershell >nul 2>&1
if errorlevel 1 exit /b 0
echo.
echo Stato di PowerShell:
powershell -NoProfile -Command "$a = Get-Command clear -ErrorAction SilentlyContinue; if ($a) { '  [OK] gia'' disponibile: ' + $a.CommandType + ' -> ' + $a.Definition } else { '  [INFO] assente. Aggiungi al profilo la riga:'; '           Set-Alias -Name clear -Value Clear-Host' }" 2>nul
exit /b 0

rem ------------------------------------------------------------
:usage
echo.
echo  clear-alias.bat - comando "clear" in cmd.exe
echo.
echo  Uso:
echo    clear-alias.bat              installa (o ripara) lo shim
echo    clear-alias.bat /uninstall   rimuove lo shim
echo    clear-alias.bat /?           questo aiuto
echo.
echo  Non modifica registro, PATH o privilegi: crea solo un file
echo  clear.cmd in %LOCALAPPDATA%\Microsoft\WindowsApps
echo.
exit /b 0
