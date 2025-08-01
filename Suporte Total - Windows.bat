@echo off
:: ===================================================================
:: Arquivo: manutencao_windows.bat
:: Descrição: Script de manutenção e atualização de sistema Windows
:: Criador: https://github.com/MBritoS19
::===================================================================

:: 1) Verificar se o script foi executado como Administrador
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo [!] Execute este script como Administrador!
    pause
    exit /b
)

echo.
echo ================================================================
echo       INICIANDO ROTINA DE MANUTENCAO E ATUALIZACAO
echo ================================================================
echo.

:: 2) Atualizar todos os aplicativos instalados via Winget (se disponível)
echo [1/10] Atualizando aplicativos via Winget...
winget upgrade --all --silent

:: 3) Forçar checagem de atualizacoes do Windows Update
echo [2/10] Solicitando atualizacoes do Windows Update...
powershell -Command "Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser > $null; \
    Import-Module PSWindowsUpdate; \
    Get-WindowsUpdate -AcceptAll -Install -AutoReboot"

:: 4) Limpeza de arquivos temporários do usuário
echo [3/10] Limpando pasta TEMP do usuario...
del /F /Q "%TEMP%\*" >nul 2>&1
for /d %%p in ("%TEMP%\*") do rmdir "%%p" /S /Q

:: 5) Limpeza de arquivos temporários do sistema
echo [4/10] Limpando pasta TEMP do sistema...
del /F /Q "C:\Windows\Temp\*" >nul 2>&1
for /d %%p in ("C:\Windows\Temp\*") do rmdir "%%p" /S /Q

:: 6) Limpeza de cache de Windows Update
echo [5/10] Limpando cache do Windows Update...
net stop wuauserv
net stop bits
rd /S /Q "C:\Windows\SoftwareDistribution\Download"
net start bits
net start wuauserv

:: 7) Limpeza com CleanMgr (Disco C:)
echo [6/10] Executando CleanMgr para disco C:...
cleanmgr /sagerun:1

:: 8) Verificação e reparo de integridade do sistema
echo [7/10] Executando DISM e SFC...
dism /online /cleanup-image /restorehealth
sfc /scannow

:: 9) Checagem de disco (Chkdsk) - marca para próxima reinicialização
echo [8/10] Agendando CHKDSK na proxima reinicializacao...
chkdsk C: /f /r

:: 10) Desfragmentação / Otimização de volume (se SSD, ignora)
echo [9/10] Desfragmentando / Otimizando volume C:...
powershell -Command "Optimize-Volume -DriveLetter C -Defrag -Verbose"

:: 11) Limpeza de DNS e rede
echo [10/10] Resetando rede e DNS...
ipconfig /flushdns
netsh winsock reset
netsh int ip reset

echo.
echo ================================================================
echo       ROTINA DE MANUTENCAO CONCLUIDA!
echo ================================================================
echo.
pause
exit /b
