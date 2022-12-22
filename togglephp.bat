@echo off
:: Made by GusMilky

:: BatchGotAdmin by Eneerge https://sites.google.com/site/eneerge/scripts/batchgotadmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

@echo off


setlocal ENABLEDELAYEDEXPANSION
:: for each line in the file paths.config
SET /a TOTAL_PHP_PATHS=0
SET NO_PHP_PATH=%PATH%
SET PATHS=;

FOR /F %%i IN (paths.config) DO (
    :: Remove double semi-colons ::
    SET NO_PHP_PATH=!NO_PHP_PATH:;;=;!

    if exist %%i (
        :: Remove the PHP path from the PATH variable
        SET NO_PHP_PATH=!NO_PHP_PATH:%%i=!

        SET PATHS=!PATHS!;%%i
        SET /a TOTAL_PHP_PATHS=TOTAL_PHP_PATHS+1
    )
)

IF %TOTAL_PHP_PATHS% LSS 1 (
    @echo "Nenhum caminho de PHP encontrado."
    @pause
    exit
)

@ECHO ESCOLHA SUA VERSÃO:
set /a i=1
set options=0
@echo 0 - Nenhuma (remover PHP das variáves de ambiente)
for %%a in (%PATHS%) do (
    @echo !i! - %%a
    set options=!options!!i!
    set /a i=i+1
    if !i! GTR 9 (
        goto :maxpaths
    )
)

:maxpaths
@CHOICE /M "Sua escolha" /D 1 /C !options! /T 100
SET /a CHOOSENOPTION=%ERRORLEVEL%-1
set /a i=0

for %%a in (%PATHS%) do (
    set /a i=i+1
    if !i! EQU !CHOOSENOPTION! (
        @SETX /m PATH "%NO_PHP_PATH%;%%a"
        echo Voce agora esta usando o PHP localizado em: %%a
    )
)

endlocal
pause
exit
