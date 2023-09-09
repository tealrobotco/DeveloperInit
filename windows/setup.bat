@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

:: BatchGotAdmin
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
    GOTO :StartProgram

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

:StartProgram

:: Reusable Vars
SET HEADERDIV=##############################################

:: Create and Print Array of Apps to Install from the MS App Store
CALL ECHO %%HEADERDIV%%
CALL ECHO Install List
CALL ECHO %%HEADERDIV%%
SET x=0
FOR /f "skip=1 usebackq tokens=1-3 delims=," %%a IN ("requirements.csv") DO (
    SET apps[!x!].ID=%%a
    SET apps[!x!].Name=%%b
    SET apps[!x!].Source=%%c
    CALL ECHO %%b
    SET /a "x+=1"
)
CALL ECHO Posh Git
CALL ECHO.
CALL ECHO.

:: Confirm installing list of programs
:UseSetPrompt
    setlocal EnableExtensions DisableDelayedExpansion
    IF exist "%SystemRoot%\System32\choice.exe" GOTO UseChoice

    SET "UserChoice=N"
    SET "UserChoice=!UserChoice: =!"
    IF /I not "!UserChoice!" == "Y" ENDLOCAL & EXIT /B
    GOTO :InstallLoop

:UseChoice
    CHOICE /C YN /N /M "Are you sure you want to install/upgrade these apps (Y/[N])?"
    IF not errorlevel 2 IF errorlevel 1 GOTO :Install
    EXIT /B

:: Install Programs from Windows Store
:Install
    SET x=0
    CALL ECHO.
    CALL ECHO.
    CALL ECHO %%HEADERDIV%%
    CALL ECHO Starting Installation
    CALL ECHO %%HEADERDIV%%

:InstallLoop
    IF defined apps[%x%].Name (
        CALL ECHO Installing %%apps[%x%].Name%% - %%apps[%x%].ID%% from %%apps[%x%].Source%%
        CALL winget install --accept-package-agreements --accept-source-agreements --id %%apps[%x%].ID%% --source %%apps[%x%].Source%%
        IF errorlevel 2 (
            EXIT /B
        )
        SET /a "x+=1"
        GOTO :InstallLoop
    )

:Install Posh Git
CALL ECHO Installing Posh Git
powershell.exe Install-Module -Name PowerShellGet -Force -Scope CurrentUser -AllowClobber
powershell.exe Install-Module PSReadLine -Scope CurrentUser -Force
powershell.exe Install-PackageProvider NuGet -Scope CurrentUser -Force
powershell.exe Install-Module posh-git -Scope CurrentUser -Force

CALL ECHO Writing to Profile
copy Microsoft.PowerShell_profile.ps1 %PROFILE%

:END
    CALL ECHO.
    CALL ECHO.
    CALL ECHO Done!
    ENDLOCAL