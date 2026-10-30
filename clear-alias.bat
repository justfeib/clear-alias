@echo off
setlocal EnableExtensions

rem ============================================================
rem  clear-alias.bat
rem
rem  Makes the "clear" command available in cmd.exe.
rem
rem  How: it creates a tiny shim file "clear.cmd" (contents:
rem  "cls") inside %LOCALAPPDATA%\Microsoft\WindowsApps, a folder
rem  that is already in the user PATH by default.
rem
rem  What it does NOT do: no registry, no AutoRun, no setx,
rem  no PATH changes, no administrator privileges. To undo
rem  everything, just delete that single file - or run
rem  /uninstall.
rem
rem  Usage:
rem    clear-alias.bat              install or repair
rem    clear-alias.bat /uninstall   remove
rem    clear-alias.bat /?           this help
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
echo [ERROR] Unknown option: %~1
echo         Run "%~nx0 /?" for help.
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

rem Write the shim: two lines, Windows line endings (CRLF).
(echo @echo off&echo cls)>"%TARGET%\%SHIM%" 2>nul
if not exist "%TARGET%\%SHIM%" goto :writefail

echo.
if defined PREEXISTING (
    echo [OK] Shim already existed, rewritten:
) else (
    echo [OK] Shim created:
)
echo      %TARGET%\%SHIM%
echo.
echo      Contents:
echo        @echo off
echo        cls
echo.

call :whereclear
call :psstatus

echo.
echo Done. Open a cmd and type "clear": it should wipe the screen
echo like "cls". No restart needed: the folder was already in
echo PATH, so it works in cmd windows that are already open too.
echo.
echo To remove it: "%~nx0 /uninstall"
exit /b 0

rem ------------------------------------------------------------
:uninstall
if not exist "%TARGET%\%SHIM%" (
    echo.
    echo [INFO] Nothing to remove: %TARGET%\%SHIM% does not exist.
    exit /b 0
)
del /q "%TARGET%\%SHIM%" 2>nul
if exist "%TARGET%\%SHIM%" (
    echo.
    echo [ERROR] Cannot delete %TARGET%\%SHIM%
    echo         Close any open cmd windows and try again.
    exit /b 1
)
echo.
echo [OK] Removed: %TARGET%\%SHIM%
echo.
call :whereclear
echo.
echo Note: "cls" in cmd and "clear" in PowerShell were not touched
echo and keep working.
exit /b 0

rem ------------------------------------------------------------
:notarget
echo.
echo [ERROR] Folder missing or not writable:
echo         %TARGET%
echo.
echo         This can happen if the folder was removed or if the
echo         user has no write permission on it.
echo         In that case: create any folder, add it to the user
echo         PATH, and copy a %SHIM% file in there containing the
echo         two lines above.
echo         I do not add the PATH entry myself, to avoid changing
echo         your configuration without you noticing.
exit /b 1

rem ------------------------------------------------------------
:writefail
echo.
echo [ERROR] Write failed on:
echo         %TARGET%\%SHIM%
exit /b 1

rem ------------------------------------------------------------
rem  Subroutine: does the folder exist and is it writable?
:checkdir
set "PROBE=%~1\.__clear_alias_probe.tmp"
if not exist "%~1\" exit /b 1
2>nul>"%PROBE%" echo probe
if not exist "%PROBE%" exit /b 1
del /q "%PROBE%" >nul 2>&1
exit /b 0

rem  Subroutine: where does "clear" resolve right now?
:whereclear
echo Checking where "clear" resolves right now:
where clear 2>nul
if errorlevel 1 (
    echo   [WARNING] "clear" was not found in PATH.
    echo             Check that %TARGET% is in your user PATH.
) else (
    echo   [OK] Found. If more than one line is listed above, cmd
    echo        uses the FIRST one: if that is not the shim, another
    echo        clear command, for example a clear.exe, comes first
    echo        in PATH.
)
exit /b 0

rem  Subroutine: does PowerShell already have it or not?
:psstatus
where powershell >nul 2>&1
if errorlevel 1 exit /b 0
echo.
echo PowerShell status:
powershell -NoProfile -Command "$a = Get-Command clear -ErrorAction SilentlyContinue; if ($a) { '  [OK] already available: ' + $a.CommandType + ' -> ' + $a.Definition } else { '  [INFO] not available. Add this line to your profile:'; '           Set-Alias -Name clear -Value Clear-Host' }" 2>nul
exit /b 0

rem ------------------------------------------------------------
:usage
echo.
echo  clear-alias.bat - the "clear" command for cmd.exe
echo.
echo  Usage:
echo    clear-alias.bat              install or repair the shim
echo    clear-alias.bat /uninstall   remove the shim
echo    clear-alias.bat /?           this help
echo.
echo  Does not modify the registry, PATH or privileges: it only
echo  creates a clear.cmd file in %LOCALAPPDATA%\Microsoft\WindowsApps
echo.
exit /b 0
