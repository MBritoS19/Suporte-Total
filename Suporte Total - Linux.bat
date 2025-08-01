#!/bin/bash

# ============================================================
# Script de Manutenção para Sistemas Linux (Debian/Ubuntu)
# Atualizações, limpeza, integridade e rede
# Criador: https://github.com/MBritoS19
# ============================================================

# 1) Verificação de privilégios
if [[ $EUID -ne 0 ]]; then
   echo "[!] Este script precisa ser executado como root (sudo)."
   exit 1
fi

echo
echo "==============================================="
echo " INICIANDO MANUTENÇÃO DO SISTEMA LINUX"
echo "==============================================="

# 2) Atualizar pacotes do sistema
echo "[1/10] Atualizando pacotes do sistema..."
apt update -y && apt upgrade -y && apt dist-upgrade -y

# 3) Remover pacotes e kernels antigos
echo "[2/10] Removendo pacotes desnecessários..."
apt autoremove -y
apt autoclean -y
apt clean -y

# 4) Verificação de pacotes quebrados
echo "[3/10] Verificando e corrigindo pacotes quebrados..."
dpkg --configure -a
apt install -f -y

# 5) Verificação de integridade do sistema de arquivos raiz
echo "[4/10] Verificando integridade do sistema de arquivos..."
touch /forcefsck
echo "→ A verificação ocorrerá na próxima reinicialização."

# 6) Verificação de integridade de arquivos críticos
echo "[5/10] Verificando integridade de arquivos do sistema..."
debsums -s 2>/dev/null || echo "→ 'debsums' não instalado, execute: apt install debsums"

# 7) Verificar espaço em disco
echo "[6/10] Uso de espaço em disco:"
df -h

# 8) Verificar serviços em falha
echo "[7/10] Verificando serviços com falha:"
systemctl --failed

# 9) Limpar cache do Snap (se houver)
if command -v snap >/dev/null 2>&1; then
    echo "[8/10] Limpando cache de snaps antigos..."
    snap list --all | awk '/disabled/{print $1, $2}' |
    while read snapname version; do
        snap remove "$snapname" --revision="$version"
    done
else
    echo "[8/10] Snap não instalado – ignorado."
fi

# 10) Limpeza de arquivos temporários
echo "[9/10] Limpando arquivos temporários..."
rm -rf /tmp/*
rm -rf /var/tmp/*
journalctl --vacuum-time=7d

# 11) Reinicialização opcional da rede e DNS
echo "[10/10] Reinicializando rede e limpando DNS..."
systemctl restart NetworkManager
systemd-resolve --flush-caches

echo
echo "==============================================="
echo " ROTINA DE MANUTENÇÃO FINALIZADA!"
echo "==============================================="
