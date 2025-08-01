# Scripts de Suporte Total: Manutenção e Limpeza de Sistemas

Este repositório contém dois scripts para auxiliar na manutenção e limpeza de sistemas operacionais: um para **Windows (.bat)** e outro para **Linux (Debian/Ubuntu .sh)**. Eles automatizam várias tarefas comuns de otimização, atualização e verificação de integridade, visando melhorar o desempenho e a estabilidade do seu sistema.

## 🚀 Como Usar

### 1. Suporte Total - Windows.bat

Este script é projetado para sistemas Windows.

**Como Executar:**

1.  **Baixe** o arquivo `Suporte Total - Windows.bat` para o seu computador.
2.  **Clique com o botão direito** no arquivo `Suporte Total - Windows.bat`.
3.  Selecione **"Executar como administrador"**.
4.  O script será iniciado em uma janela do Prompt de Comando e exibirá as etapas de manutenção.
5.  Ao final, o script pausará e aguardará sua interação antes de fechar.

**Importante:**

* **Administrador:** É crucial executar o script como administrador para que todas as operações funcionem corretamente, especialmente as de limpeza de sistema e verificação de integridade.
* **Reinicialização:** O CHKDSK será agendado para a próxima reinicialização do sistema. É recomendável reiniciar o computador após a execução do script para que esta verificação seja realizada e outras mudanças sejam aplicadas.

### 2. Suporte Total - Linux.sh

Este script é projetado para sistemas baseados em Debian/Ubuntu.

**Como Executar:**

1.  **Baixe** o arquivo `Suporte Total - Linux.sh` para o seu computador.
2.  **Abra um terminal** na pasta onde você salvou o script.
3.  **Dê permissões de execução** ao script com o comando:
    ```bash
    chmod +x "Suporte Total - Linux.sh"
    ```
4.  **Execute o script como root** (com `sudo`):
    ```bash
    sudo ./"Suporte Total - Linux.sh"
    ```
5.  O script exibirá o progresso das tarefas no terminal.

**Importante:**

* **Root:** O script exige privilégios de root para executar as tarefas de manutenção do sistema.
* **Verificação do Sistema de Arquivos:** Uma verificação de integridade do sistema de arquivos será agendada para a próxima reinicialização.
* **`debsums`:** Se o comando `debsums` não estiver instalado, o script irá informar e sugerir a instalação. É uma ferramenta útil para verificar a integridade dos pacotes instalados.

## ⚙️ Como Funciona

Ambos os scripts foram projetados para realizar uma série de tarefas de manutenção de forma sequencial. Abaixo está um detalhamento das operações:

### Suporte Total - Windows.bat

Este script executa 11 etapas principais:

1.  **Verificação de Administrador:** Garante que o script seja executado com privilégios elevados.
2.  **Atualização Winget:** Atualiza todos os aplicativos instalados via Winget (gerenciador de pacotes do Windows), se disponível.
3.  **Windows Update:** Solicita e instala atualizações pendentes do Windows Update.
4.  **Limpeza TEMP (Usuário):** Remove arquivos temporários da pasta do usuário (`%TEMP%`).
5.  **Limpeza TEMP (Sistema):** Remove arquivos temporários da pasta do sistema (`C:\Windows\Temp`).
6.  **Limpeza Cache Windows Update:** Interrompe serviços de atualização, limpa o cache de downloads e reinicia os serviços.
7.  **CleanMgr (Disco C:):** Executa a ferramenta de Limpeza de Disco (CleanMgr) para otimizar o espaço em `C:`.
8.  **DISM e SFC:** Executa ferramentas de verificação e reparo de integridade do sistema (Deployment Image Servicing and Management e System File Checker).
9.  **CHKDSK:** Agenda uma verificação de disco (`chkdsk C: /f /r`) para corrigir erros e recuperar setores danificados na próxima inicialização.
10. **Desfragmentação/Otimização:** Otimiza o volume `C:`. Em SSDs, realiza uma otimização; em HDDs, realiza desfragmentação.
11. **Limpeza de DNS e Rede:** Libera o cache DNS e reseta as configurações de rede (Winsock e IP).

### Suporte Total - Linux.sh

Este script executa 11 etapas principais:

1.  **Verificação de Privilégios:** Garante que o script seja executado como `root`.
2.  **Atualização de Pacotes:** Atualiza a lista de pacotes e realiza upgrade e dist-upgrade.
3.  **Remoção de Pacotes Antigos:** Limpa pacotes desnecessários, kernels antigos e o cache de pacotes APT.
4.  **Correção de Pacotes Quebrados:** Verifica e corrige dependências de pacotes e pacotes "quebrados".
5.  **Verificação do Sistema de Arquivos (fsck):** Agenda uma verificação de integridade do sistema de arquivos raiz para a próxima reinicialização.
6.  **Verificação de Integridade de Arquivos Críticos (debsums):** Verifica a integridade dos arquivos de sistema instalados via pacotes Debian (requer `debsums`).
7.  **Uso de Espaço em Disco:** Exibe o uso atual de espaço em disco de forma legível.
8.  **Verificação de Serviços com Falha:** Lista quaisquer serviços do sistema que estejam em estado de falha.
9.  **Limpeza de Cache do Snap:** Remove versões antigas e desabilitadas de pacotes Snap para liberar espaço.
10. **Limpeza de Arquivos Temporários:** Remove arquivos de `/tmp`, `/var/tmp` e limpa o journal do sistema.
11. **Reinicialização de Rede e DNS:** Reinicia o serviço NetworkManager e limpa o cache DNS do sistema.

---

## ⚠️ Aviso

* Sempre revise o conteúdo de scripts baixados da internet antes de executá-los, especialmente aqueles que requerem privilégios de administrador/root.
* Embora os scripts sejam projetados para serem seguros, é sempre uma boa prática fazer um backup de dados importantes antes de executar rotinas de manutenção profundas.

---

## 🤝 Contribuições

Contribuições são bem-vindas! Se você tiver sugestões de melhorias, otimizações ou quiser reportar um problema, sinta-se à vontade para abrir uma *issue* ou enviar um *pull request*.

---

**Criador:** [MBritoS19](https://github.com/MBritoS19)
