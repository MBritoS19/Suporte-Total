@echo off
:: ===================================================================
:: Arquivo: manutencao_windows_final.bat
:: Descrição: Script interativo de manutenção e atualização de sistema Windows
:: Criador: https://github.com/MBritoS19
::===================================================================

:MENU
cls
echo ================================================================
echo       MENU DE MANUTENCAO E ATUALIZACAO DO WINDOWS
echo ================================================================
echo.
echo Escolha uma das opcoes abaixo (digite o numero e pressione Enter):
echo.
echo [1]  - Atualizar aplicativos via Winget
echo [2]  - Forcar atualizacoes do Windows Update
echo [3]  - Limpar arquivos temporarios (usuario e sistema)
echo [4]  - Limpar cache do Windows Update
echo [5]  - Executar CleanMgr (limpeza de disco C:)
echo [6]  - Verificar e reparar integridade do sistema (DISM e SFC)
echo [7]  - Agendar CHKDSK na proxima reinicializacao
echo [8]  - Desfragmentar / Otimizar volume C:
echo [9]  - Resetar rede e DNS
echo [10] - Limpar cache de navegadores (Chrome, Edge, Firefox)
echo [11] - Verificacao e atualizacao de drivers
echo [12] - Executar todas as rotinas de manutencao
echo [0]  - Sair
echo.
set /p "escolha=Digite sua escolha: "

if "%escolha%"=="1" goto :ATUALIZAR_WINGET
if "%escolha%"=="2" goto :WINDOWS_UPDATE
if "%escolha%"=="3" goto :LIMPEZA_TEMP
if "%escolha%"=="4" goto :LIMPEZA_CACHE_WU
if "%escolha%"=="5" goto :CLEANMGR
if "%escolha%"=="6" goto :REPARO_SISTEMA
if "%escolha%"=="7" goto :CHKDSK
if "%escolha%"=="8" goto :DESFRAGMENTAR
if "%escolha%"=="9" goto :RESETA_REDE
if "%escolha%"=="10" goto :LIMPEZA_NAVEGADORES
if "%escolha%"=="11" goto :VERIFICAR_DRIVERS
if "%escolha%"=="12" goto :TODAS
if "%escolha%"=="0" goto :FIM

echo.
echo Opcao invalida. Pressione qualquer tecla para voltar ao menu.
pause > nul
goto :MENU

:: -------------------------------------------------------------------
:: Sub-rotinas (Funcoes)
:: -------------------------------------------------------------------

:CHECAR_ADMIN
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo [!] Esta acao requer privilegios de Administrador. Execute o script como Administrador.
    pause
    goto :MENU
)
goto :EOF

:ATUALIZAR_WINGET
echo [1] Atualizando aplicativos via Winget...
winget upgrade --all --silent
if %ERRORLEVEL% NEQ 0 (
    echo [!] Erro ao atualizar aplicativos via Winget. O Winget pode nao estar instalado.
) else (
    echo [✓] Winget atualizado com sucesso.
)
goto :PAUSE_E_MENU

:WINDOWS_UPDATE
call :CHECAR_ADMIN
echo [2] Solicitando atualizacoes do Windows Update...
powershell -Command "Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser > $null; Import-Module PSWindowsUpdate; Get-WindowsUpdate -AcceptAll -Install -AutoReboot"
if %ERRORLEVEL% NEQ 0 (
    echo [!] Erro ao buscar e instalar atualizacoes do Windows Update.
) else (
    echo [✓] Atualizacoes do Windows Update solicitadas com sucesso.
)
goto :PAUSE_E_MENU

:LIMPEZA_TEMP
call :CHECAR_ADMIN
echo [3] Limpando pasta TEMP do usuario...
del /F /Q "%TEMP%\*" >nul 2>&1
for /d %%p in ("%TEMP%\*") do rmdir "%%p" /S /Q
echo [✓] Pasta TEMP do usuario limpa.
echo.
echo [3] Limpando pasta TEMP do sistema...
del /F /Q "C:\Windows\Temp\*" >nul 2>&1
for /d %%p in ("C:\Windows\Temp\*") do rmdir "%%p" /S /Q
echo [✓] Pasta TEMP do sistema limpa.
goto :PAUSE_E_MENU

:LIMPEZA_CACHE_WU
call :CHECAR_ADMIN
echo [4] Limpando cache do Windows Update...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
rd /S /Q "C:\Windows\SoftwareDistribution\Download" >nul 2>&1
net start bits >nul 2>&1
net start wuauserv >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [!] Erro ao limpar o cache do Windows Update.
) else (
    echo [✓] Cache do Windows Update limpo.
)
goto :PAUSE_E_MENU

:CLEANMGR
call :CHECAR_ADMIN
echo [5] Executando CleanMgr para disco C:...
echo.
echo ATENCAO: A ferramenta de Limpeza de Disco sera iniciada em uma nova janela.
echo O processo pode levar alguns minutos para ser concluido.
echo.
cleanmgr /sagerun:1
if %ERRORLEVEL% NEQ 0 (
    echo [!] Erro ao executar o CleanMgr.
) else (
    echo [✓] CleanMgr executado com sucesso.
)
goto :PAUSE_E_MENU

:REPARO_SISTEMA
call :CHECAR_ADMIN
echo [6] Executando DISM e SFC...
echo.
dism /online /cleanup-image /restorehealth
if %ERRORLEVEL% NEQ 0 (
    echo [!] Erro ao executar DISM. Verifique o log para mais detalhes.
) else (
    echo [✓] DISM executado com sucesso.
)
echo.
sfc /scannow
if %ERRORLEVEL% NEQ 0 (
    echo [!] Erro ao executar SFC. Verifique o log para mais detalhes.
) else (
    echo [✓] SFC executado com sucesso.
)
goto :PAUSE_E_MENU

:CHKDSK
call :CHECAR_ADMIN
echo [7] Agendando CHKDSK na proxima reinicializacao...
echo.
echo ATENCAO: A verificacao do disco sera executada na proxima vez que o computador for reiniciado.
echo Ela pode levar um tempo consideravel dependendo do tamanho e do estado do disco.
echo.
chkdsk C: /f /r
if %ERRORLEVEL% NEQ 0 (
    echo [!] Erro ao agendar CHKDSK.
) else (
    echo [✓] CHKDSK agendado com sucesso.
)
goto :PAUSE_E_MENU

:DESFRAGMENTAR
call :CHECAR_ADMIN
echo [8] Desfragmentando / Otimizando volume C:...
powershell -Command "Optimize-Volume -DriveLetter C -Defrag -Verbose"
if %ERRORLEVEL% NEQ 0 (
    echo [!] Erro ao desfragmentar/otimizar o volume C:.
) else (
    echo [✓] Volume C: otimizado com sucesso.
)
goto :PAUSE_E_MENU

:RESETA_REDE
echo [9] Resetando rede e DNS...
ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [!] Erro ao resetar a configuracao de rede.
) else (
    echo [✓] Configuracao de rede e DNS resetada.
)
goto :PAUSE_E_MENU

:LIMPEZA_NAVEGADORES
echo [10] Limpando cache de navegadores...
echo.
echo Limpando Google Chrome...
rmdir /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" >nul 2>&1
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" (
    echo [!] Nao foi possivel limpar o cache do Chrome. Certifique-se de que o navegador esta fechado.
) else (
    echo [✓] Cache do Chrome limpo com sucesso.
)

echo.
echo Limpando Microsoft Edge...
rmdir /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" >nul 2>&1
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" (
    echo [!] Nao foi possivel limpar o cache do Edge. Certifique-se de que o navegador esta fechado.
) else (
    echo [✓] Cache do Edge limpo com sucesso.
)

echo.
echo Limpando Mozilla Firefox...
for /d %%d in ("%APPDATA%\Mozilla\Firefox\Profiles\*") do (
    rmdir /s /q "%%d\cache2" >nul 2>&1
)
if %ERRORLEVEL% NEQ 0 (
    echo [!] Nao foi possivel limpar o cache do Firefox. Certifique-se de que o navegador esta fechado.
) else (
    echo [✓] Cache do Firefox limpo com sucesso.
)

goto :PAUSE_E_MENU

:VERIFICAR_DRIVERS
call :CHECAR_ADMIN
echo [11] Verificando e atualizando drivers...
echo.
echo Tentando verificar e atualizar drivers via PowerShell...
echo.
powershell -Command "Get-PnpDevice -Class 'System','Display','Audio','Net' | Where-Object { $_.Status -eq 'Error' } | Select-Object FriendlyName, Status"
echo.
echo Caso algum driver apareca com status de erro, voce pode tentar atualiza-lo ou reinstala-lo.
echo Esta acao nao atualiza automaticamente, apenas lista os drivers com problemas.
goto :PAUSE_E_MENU

:TODAS
call :ATUALIZAR_WINGET
call :WINDOWS_UPDATE
call :LIMPEZA_TEMP
call :LIMPEZA_CACHE_WU
call :CLEANMGR
call :REPARO_SISTEMA
call :CHKDSK
call :DESFRAGMENTAR
call :RESETA_REDE
call :LIMPEZA_NAVEGADORES
call :VERIFICAR_DRIVERS
goto :FIM

:PAUSE_E_MENU
echo.
echo Tarefa concluida. Pressione qualquer tecla para voltar ao menu.
pause > nul
goto :MENU

:FIM
echo.
echo ================================================================
echo       ROTINA DE MANUTENCAO CONCLUIDA!
echo ================================================================
echo.
pause
exit /b