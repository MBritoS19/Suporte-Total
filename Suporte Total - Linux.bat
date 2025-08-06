#!/bin/bash

# ===================================================================
# Arquivo: manutencao_linux_interativa.sh
# Descrição: Script interativo de manutenção para sistemas Linux (Debian/Ubuntu)
# Criador: https://github.com/MBritoS19
# ===================================================================

# -------------------------------------------------------------------
# Funções de Verificação de Privilégios
# -------------------------------------------------------------------
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "[!] Esta acao requer privilegios de root (sudo). Execute o script com 'sudo'."
        read -n 1 -s -r -p "Pressione qualquer tecla para voltar ao menu."
        return 1
    fi
    return 0
}

# -------------------------------------------------------------------
# Funções de Manutenção
# -------------------------------------------------------------------

update_packages() {
    check_root || return
    echo "[1] Atualizando pacotes do sistema..."
    apt update -y
    if [ $? -ne 0 ]; then
        echo "[!] Erro ao atualizar a lista de pacotes."
        return
    fi
    apt upgrade -y
    if [ $? -ne 0 ]; then
        echo "[!] Erro ao atualizar pacotes."
        return
    fi
    apt dist-upgrade -y
    if [ $? -ne 0 ]; then
        echo "[!] Erro ao fazer dist-upgrade."
        return
    fi
    echo "[✓] Pacotes do sistema atualizados com sucesso."
}

remove_packages() {
    check_root || return
    echo "[2] Removendo pacotes desnecessários..."
    apt autoremove -y
    if [ $? -ne 0 ]; then
        echo "[!] Erro ao remover pacotes órfãos."
        return
    fi
    apt autoclean -y
    if [ $? -ne 0 ]; then
        echo "[!] Erro ao limpar cache de pacotes baixados."
        return
    fi
    apt clean -y
    if [ $? -ne 0 ]; then
        echo "[!] Erro ao limpar cache de pacotes."
        return
    fi
    echo "[✓] Pacotes desnecessários e cache removidos."
}

fix_broken_packages() {
    check_root || return
    echo "[3] Verificando e corrigindo pacotes quebrados..."
    dpkg --configure -a
    apt install -f -y
    if [ $? -ne 0 ]; then
        echo "[!] Erro ao corrigir pacotes quebrados."
    else
        echo "[✓] Pacotes quebrados verificados e corrigidos."
    fi
}

check_filesystem() {
    check_root || return
    echo "[4] Verificando integridade do sistema de arquivos..."
    echo
    echo "ATENCAO: A verificacao do sistema de arquivos (fsck) será agendada para a próxima reinicialização."
    echo "Ela pode levar um tempo consideravel dependendo do tamanho e do estado do disco."
    echo
    touch /forcefsck
    if [ $? -ne 0 ]; then
        echo "[!] Erro ao agendar a verificacao de sistema de arquivos."
    else
        echo "[✓] Verificacao de sistema de arquivos agendada com sucesso."
    fi
}

check_file_integrity() {
    echo "[5] Verificando integridade de arquivos do sistema..."
    if ! command -v debsums &> /dev/null; then
        echo "→ 'debsums' não está instalado."
        echo "→ Para instalá-lo, execute: sudo apt install debsums"
    else
        debsums -s
        if [ $? -ne 0 ]; then
            echo "[!] Foram encontradas inconsistencias nos arquivos. Verifique a saida acima."
        else
            echo "[✓] Nenhuma inconsistencia encontrada."
        fi
    fi
}

check_disk_space() {
    echo "[6] Uso de espaço em disco:"
    df -h
}

check_failed_services() {
    echo "[7] Verificando serviços com falha:"
    systemctl --failed
    if [ $? -ne 0 ]; then
        echo "[✓] Nenhum serviço com falha encontrado."
    fi
}

clean_snap_cache() {
    if command -v snap &> /dev/null; then
        echo "[8] Limpando cache de snaps antigos..."
        snap list --all | awk '/disabled/{print $1, $2}' | while read snapname version; do
            snap remove "$snapname" --revision="$version"
        done
        echo "[✓] Cache de snaps antigos limpo."
    else
        echo "[8] Snap não instalado – ignorado."
    fi
}

clean_temp_files() {
    check_root || return
    echo "[9] Limpando arquivos temporários..."
    rm -rf /tmp/*
    if [ $? -ne 0 ]; then
        echo "[!] Erro ao limpar /tmp."
    fi
    rm -rf /var/tmp/*
    if [ $? -ne 0 ]; then
        echo "[!] Erro ao limpar /var/tmp."
    fi
    journalctl --vacuum-time=7d
    if [ $? -ne 0 ]; then
        echo "[!] Erro ao limpar o journal."
    else
        echo "[✓] Arquivos temporários e logs antigos do journal limpos."
    fi
}

reset_network() {
    check_root || return
    echo "[10] Reinicializando rede e limpando DNS..."
    systemctl restart NetworkManager
    if [ $? -ne 0 ]; then
        echo "[!] Erro ao reiniciar o NetworkManager."
    else
        echo "[✓] NetworkManager reinicializado."
    fi
    systemd-resolve --flush-caches
    if [ $? -ne 0 ]; then
        echo "[!] Erro ao limpar o cache do DNS."
    else
        echo "[✓] Cache do DNS limpo."
    fi
}

run_all() {
    update_packages
    remove_packages
    fix_broken_packages
    check_filesystem
    check_file_integrity
    check_disk_space
    check_failed_services
    clean_snap_cache
    clean_temp_files
    reset_network
}

# -------------------------------------------------------------------
# Menu Principal
# -------------------------------------------------------------------
while true; do
    clear
    echo "==============================================="
    echo "   MENU DE MANUTENCAO DO SISTEMA LINUX"
    echo "==============================================="
    echo
    echo "Escolha uma opcao:"
    echo
    echo "[1]  - Atualizar pacotes do sistema"
    echo "[2]  - Remover pacotes e kernels antigos"
    echo "[3]  - Corrigir pacotes quebrados"
    echo "[4]  - Agendar verificacao de disco (fsck)"
    echo "[5]  - Verificar integridade de arquivos do sistema"
    echo "[6]  - Verificar espaco em disco"
    echo "[7]  - Verificar servicos com falha"
    echo "[8]  - Limpar cache do Snap"
    echo "[9]  - Limpar arquivos temporarios"
    echo "[10] - Reinicializar rede e limpar DNS"
    echo "[11] - Executar todas as rotinas de manutencao"
    echo "[0]  - Sair"
    echo
    read -p "Digite sua escolha: " choice

    case "$choice" in
        1) update_packages ;;
        2) remove_packages ;;
        3) fix_broken_packages ;;
        4) check_filesystem ;;
        5) check_file_integrity ;;
        6) check_disk_space ;;
        7) check_failed_services ;;
        8) clean_snap_cache ;;
        9) clean_temp_files ;;
        10) reset_network ;;
        11) run_all ;;
        0) echo "Saindo..." ; exit 0 ;;
        *) echo "Opcao invalida." ;;
    esac

    echo
    read -n 1 -s -r -p "Pressione qualquer tecla para voltar ao menu..."
done