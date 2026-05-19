#!/bin/bash

# Autor: Nelio Júnior
# Data: 09/05/2026
# Descrição: Script de configuração automática pós-instalação do Arch Linux.
# Versão: 3.0

# Descomentar se quiser ativar para o script parar caso aconteca algum erro.
#set -euo pipefail

# =========================
# Utilitários
# =========================

ask_yes_no() {
    local prompt="$1"
    local default="${2:-S}"
    local resposta

    if [[ "$default" == "S" ]]; then
        read -rp "$prompt [S/n]: " resposta
        resposta="${resposta:-S}"
    else
        read -rp "$prompt [s/N]: " resposta
        resposta="${resposta:-N}"
    fi

    resposta="$(echo "$resposta" | tr '[:lower:]' '[:upper:]')"

    [[ "$resposta" == "S" ]]
}

check_not_root() {
    if [[ "$EUID" -eq 0 ]]; then
        echo "Por favor, não execute este script como root."
        echo "Execute como usuário normal com sudo configurado."
        exit 1
    fi
}

check_sudo() {
    echo "Verificando sudo..."
    sudo -v
}

safe_source_file() {
    local file="$1"

    if [[ -f "$file" ]]; then
        # shellcheck disable=SC1090
        source "$file"
    fi
}

# =========================
# Pacman / Sistema
# =========================

configure_pacman() {
    echo "Configurando pacman..."

    sudo sed -i 's/^#Color/Color/' /etc/pacman.conf

    if grep -q '^#ParallelDownloads' /etc/pacman.conf; then
        sudo sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 10/' /etc/pacman.conf
    elif grep -q '^ParallelDownloads' /etc/pacman.conf; then
        sudo sed -i 's/^ParallelDownloads.*/ParallelDownloads = 10/' /etc/pacman.conf
    else
        echo 'ParallelDownloads = 10' | sudo tee -a /etc/pacman.conf > /dev/null
    fi
}

enable_multilib() {
    echo "Ativando repositório multilib..."

    if grep -q '^\[multilib\]' /etc/pacman.conf; then
        echo "Multilib já está ativo."
        return
    fi

    sudo sed -i '/^#\[multilib\]/,/^#Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf
}

update_system() {
    echo "Atualizando sistema..."
    sudo pacman -Syu --noconfirm
}

install_packages() {
    echo "Instalando pacotes principais..."

    sudo pacman -S --needed --noconfirm \
        base-devel \
        git \
        curl \
        wget \
        zsh \
        nvm \
        steam \
        mangohud \
        openrgb \
        filezilla \
        discord \
        spotify-launcher \
        cups \
        cups-filters \
        avahi \
        nss-mdns \
        ghostscript \
        gsfonts \
        dkms \
        linux-headers \
        fastfetch \
        telegram-desktop \
        gimp \
        obs-studio \
        inkscape \
        qbittorrent \
        audacity \
        fuse2 \
        jdk-openjdk \
        vlc \
        vlc-plugins-all \
        docker \
        docker-compose \
        croc \
        flatpak \
        partitionmanager \
        okular \
        gwenview \
        cmatrix \
        ark \
        libreoffice-still-pt-br
}

# =========================
# DNS
# =========================

configure_systemd_resolved() {
    echo "Configurando systemd-resolved..."

    sudo systemctl enable --now systemd-resolved.service
}

# =========================
# Git
# =========================

configure_git() {
    if ask_yes_no "Deseja configurar o Git?" "S"; then
        read -rp "Digite o seu nome: " name
        read -rp "Digite o seu e-mail: " email

        git config --global user.name "$name"
        git config --global user.email "$email"

        echo "Git configurado."
    else
        echo "Você escolheu não configurar o Git."
    fi
}

# =========================
# AB Download Manager
# =========================

install_ab_download_manager() {
    if ask_yes_no "Deseja instalar o AB Download Manager?" "N"; then
        echo "Instalando AB Download Manager..."
        bash <(curl -fsSL https://raw.githubusercontent.com/amir1376/ab-download-manager/master/scripts/install.sh)
    else
        echo "AB Download Manager ignorado."
    fi
}

# =========================
# Impressora
# =========================

configure_printer() {
    if ! ask_yes_no "Deseja configurar uma impressora agora?" "S"; then
        echo "Configuração de impressora ignorada."
        return
    fi

    echo "Configurando serviço de impressão..."

    sudo systemctl enable --now cups.service
    sudo systemctl enable --now avahi-daemon.service

    echo
    read -rp "Digite o IPv4 da impressora: " printer_ip
    read -rp "Digite o nome para salvar a impressora: " printer_name

    if [[ -z "$printer_ip" || -z "$printer_name" ]]; then
        echo "IP ou nome da impressora vazio. Cancelando configuração da impressora."
        return
    fi

    printer_name="${printer_name// /_}"

    echo
    echo "Adicionando impressora:"
    echo "Nome: $printer_name"
    echo "IP: $printer_ip"
    echo

    sudo lpadmin -p "$printer_name" -E -v "ipp://$printer_ip/ipp/print" -m everywhere
    sudo lpoptions -d "$printer_name"

    echo
    echo "Impressora configurada como padrão."

    if ask_yes_no "Deseja imprimir uma página de teste?" "N"; then
        echo "Teste de impressão Arch Linux" | lp -d "$printer_name"
        echo "Página de teste enviada."
    fi
}

# =========================
# ZSH / Oh My Zsh
# =========================

configure_zsh() {
    if ! ask_yes_no "Deseja configurar ZSH e Oh My Zsh?" "S"; then
        echo "Configuração do ZSH ignorada."
        return
    fi

    install_oh_my_zsh() {
        if [[ -d "$HOME/.oh-my-zsh" ]]; then
            echo "Oh My Zsh já está instalado."
            return
        fi

        echo "Instalando Oh My Zsh..."
        RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    }

    install_plugin() {
        local repo_url="$1"
        local target_dir="$2"

        if [[ -d "$target_dir" ]]; then
            echo "Plugin já instalado: $target_dir"
            return
        fi

        git clone "$repo_url" "$target_dir"
    }

    sudo chsh -s /bin/zsh "$USER"

    install_oh_my_zsh

    mkdir -p "$HOME/.oh-my-zsh/custom/plugins"

    install_plugin "https://github.com/zsh-users/zsh-autosuggestions.git" \
        "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"

    install_plugin "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
        "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

    if [[ -f "$HOME/.zshrc" ]]; then
        sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' "$HOME/.zshrc"
        sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
    fi

    echo "ZSH configurado para o usuário $USER."
    echo "Faça logout/login para aplicar o shell padrão."
}

# =========================
# Yay / AUR
# =========================

install_yay() {
    if command -v yay > /dev/null 2>&1; then
        echo "Yay já está instalado."
        return
    fi

    echo "Instalando yay..."

    mkdir -p "$HOME/Downloads"

    local build_dir="$HOME/Downloads/yay"

    rm -rf "$build_dir"
    git clone https://aur.archlinux.org/yay.git "$build_dir"

    cd "$build_dir"
    makepkg -si --noconfirm

    cd "$HOME"
    rm -rf "$build_dir"
}

install_aur_packages() {
    if ! command -v yay > /dev/null 2>&1; then
        echo "Yay não encontrado. Pulando pacotes AUR."
        return
    fi

    echo "Instalando pacotes AUR..."

    yay -S --needed --noconfirm \
        visual-studio-code-bin
}

# =========================
# Bluetooth
# =========================

configure_bluetooth() {
    if ! ask_yes_no "Deseja ativar o Bluetooth?" "S"; then
        echo "Bluetooth ignorado."
        return
    fi

    echo "Configurando Bluetooth..."

    if [[ -f /etc/bluetooth/main.conf ]]; then
        sudo sed -i 's/^#AutoEnable=.*/AutoEnable=true/' /etc/bluetooth/main.conf
        sudo sed -i 's/^AutoEnable=.*/AutoEnable=true/' /etc/bluetooth/main.conf
    fi

    sudo systemctl enable --now bluetooth.service
}

# =========================
# Xpadneo
# =========================

install_xpadneo() {
    if ! ask_yes_no "Deseja instalar o xpadneo para controle Xbox via Bluetooth?" "N"; then
        echo "xpadneo ignorado."
        return
    fi

    echo "Instalando xpadneo..."

    sudo modprobe uhid || true

    local repo_url="https://github.com/atar-axis/xpadneo.git"
    local target_dir="$HOME/Downloads/xpadneo"

    rm -rf "$target_dir"
    git clone "$repo_url" "$target_dir"

    cd "$target_dir"
    sudo ./install.sh
    sudo modprobe hid-xpadneo || true

    cd "$HOME"
    rm -rf "$target_dir"

    echo "xpadneo instalado."
}

# =========================
# Firewall
# =========================

configure_firewall() {
    if ! ask_yes_no "Deseja ativar o firewall UFW?" "S"; then
        echo "Firewall ignorado."
        return
    fi

    echo "Configurando firewall..."

    sudo systemctl enable --now ufw.service

    sudo ufw default deny incoming
    sudo ufw default allow outgoing

    sudo ufw --force enable

    echo "Firewall UFW ativado."
}

# =========================
# Docker
# =========================

configure_docker() {
    if ! ask_yes_no "Deseja configurar o Docker?" "S"; then
        echo "Docker ignorado."
        return
    fi

    echo "Configurando Docker..."

    sudo systemctl enable --now docker.service
    sudo usermod -aG docker "$USER"

    echo "Docker configurado."
    echo "Faça logout/login para o grupo docker funcionar sem sudo."
}

# =========================
# NVM / Node
# =========================

configure_nvm() {
    if ! ask_yes_no "Deseja configurar NVM e instalar Node.js?" "S"; then
        echo "NVM ignorado."
        return
    fi

    echo "Configurando NVM..."

    if ! grep -q 'init-nvm.sh' "$HOME/.zshrc" 2>/dev/null; then
        {
            echo ''
            echo '# NVM'
            echo 'source /usr/share/nvm/init-nvm.sh'
        } >> "$HOME/.zshrc"
    fi

    safe_source_file /usr/share/nvm/init-nvm.sh

    nvm install node
    nvm use node

    echo "NVM e Node.js configurados."
}

# =========================
# Cronie
# =========================

configure_cronie() {
    echo "Ativando cronie..."
    sudo systemctl enable --now cronie.service
}

# =========================
# MangoHud
# =========================

customize_mangohud() {
    echo "Configurando MangoHud..."

    mkdir -p "$HOME/.config/MangoHud"

    cat > "$HOME/.config/MangoHud/MangoHud.conf" << EOF
no_display
toggle_hud=Shift+F12
gpu_fan=1
gpu_name
gpu_voltage
gpu_mem_clock
gpu_core_clock
gpu_power
cpu_power
cpu_mhz
ram
vram
swap
EOF
}

# =========================
# Flatpak
# =========================

configure_flatpak() {
    echo "Configurando Flatpak..."

    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    if ask_yes_no "Deseja adicionar também o Flathub Beta?" "N"; then
        flatpak remote-add --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
    fi
}

# =========================
# Fstab
# =========================

add_disk_fstab() {
    if ask_yes_no "Deseja adicionar disco ao fstab?" "N"; then
        echo
        sudo blkid
        echo

        read -rp "Digite o nome do disco para comentário, ex: HD Jogos: " disk_comment
        read -rp "Digite o UUID do disco: " uuid
        read -rp "Digite o ponto de montagem, ex: /mnt/jogos: " mount_point
        read -rp "Digite o tipo de sistema de arquivos, ex: ext4, btrfs, ntfs: " fs_type

        if [[ -z "$uuid" || -z "$mount_point" || -z "$fs_type" ]]; then
            echo "Dados incompletos. Cancelando configuração do fstab."
            return
        fi

        sudo mkdir -p "$mount_point"

        echo -e "\n# $disk_comment\nUUID=$uuid $mount_point $fs_type defaults 0 0" | sudo tee -a /etc/fstab > /dev/null

        echo "Entrada adicionada ao /etc/fstab."
    else
        echo "Você escolheu não configurar disco no fstab."
    fi
}

# =========================
# Main
# =========================

main() {
    check_not_root
    check_sudo

    configure_pacman
    enable_multilib
    update_system
    install_packages

    configure_systemd_resolved

    configure_docker
    configure_flatpak
    customize_mangohud

    configure_printer

    install_ab_download_manager

    configure_zsh
    configure_nvm

    install_yay
    install_aur_packages

    configure_git
    add_disk_fstab

    echo
    echo "Configuração finalizada."
    echo "Recomendo reiniciar o sistema agora."
}

main
