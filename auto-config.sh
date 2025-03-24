#!/bin/bash

# Autor: Nelio Júnior
# Data: 11/03/2025
# Descrição: Script de configuração automática do Arch Linux.
# Versão: 2.1.3

update_system() {
  # Atualiza o sistema.
  sudo pacman -Syu --noconfirm
}

enable_systemd-resolved() {
  # Ativa o systemd-resolved para salvar cache do DNS.
  sudo systemctl enable --now systemd-resolved
}

remove_unnecessary_apps() {
  # Remove aplicativos desnecessários.
  sudo pacman -R --noconfirm gnome-music gnome-tour gnome-weather gnome-maps gnome-contacts gnome-calendar gnome-clocks snapshot totem epiphany simple-scan
}

install_packages() {
  # Instala pacotes do sistema.
  sudo pacman -S --noconfirm zsh btrfs-progs bluez bluez-utils bluez-tools blueman rclone wine mangohud reflector ufw dkms linux-headers neofetch lutris bitwarden telegram-desktop thunderbird gimp obs-studio inkscape qbittorrent audacity git timeshift fuse2 jdk-openjdk vlc ncdu docker docker-compose croc gnome-browser-connector flatpak cronie gnome-boxes
}

configure_zsh() {
  # Função para instalar o Oh My Zsh com tentativas
  install_oh_my_zsh() {
    local max_attempts=10 # Número máximo de tentativas
    local attempt=1

    echo "Instalando o Oh My Zsh..."
    while [ $attempt -le $max_attempts ]; do
        echo "Tentativa $attempt de $max_attempts..."
        # Tenta baixar e instalar
        if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 2>/dev/null; then
            # Verifica se o diretório foi criado
            if [ -d "$HOME/.oh-my-zsh" ]; then
                echo "Oh My Zsh instalado com sucesso na tentativa $attempt!"
                return 0  # Sucesso, sai da função
            fi
        fi
        echo "Falha na tentativa $attempt. Tentando novamente em 5 segundos..."
        sleep 5  # Aguarda 5 segundos antes da próxima tentativa
        attempt=$((attempt + 1))
    done

    echo "Erro: Não foi possível instalar o Oh My Zsh após $max_attempts tentativas."
    exit 1  # Falha após todas as tentativas
  }

  install_plugin() {
    local repo_url="$1"
    local target_dir="$2"
    local max_attempts=10
    local attempt=1

    echo "Tentando instalar plugin em $target_dir..."
    while [ $attempt -le $max_attempts ]; do
        echo "Tentativa $attempt de $max_attempts..."
        if git clone "$repo_url" "$target_dir" 2>/dev/null; then
            if [ -d "$target_dir" ]; then
                echo "Plugin instalado com sucesso em $target_dir na tentativa $attempt!"
                return 0
            fi
        fi
        echo "Falha na tentativa $attempt. Tentando novamente em 5 segundos..."
        sleep 5
        # Remove o diretório caso tenha sido criado parcialmente
        [ -d "$target_dir" ] && rm -rf "$target_dir"
        attempt=$((attempt + 1))
    done

    echo "Erro: Não foi possível instalar o plugin $repo_url após $max_attempts tentativas."
    exit 1
  }

  # Define o Zsh como shell padrão.
  sudo chsh -s /bin/zsh $USER
  sudo chsh -s /bin/zsh root

  # Executa a instalação do Oh My Zsh com tentativas.
  install_oh_my_zsh
  
  # Instala o plugin Zsh Autosuggestions e Zsh Syntax Highlighting com tentativas.
  install_plugin "https://github.com/zsh-users/zsh-autosuggestions.git" "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
  install_plugin "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
  # Configura o Zsh.
  sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="bira"/g' $HOME/.zshrc
  sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' $HOME/.zshrc
  
  # Configura o Zsh para o root.
  sudo -i cp -r $HOME/.oh-my-zsh /root/
  sudo -i ln -s $HOME/.zshrc /root/.zshrc
}

enable_multilib() {
  # Ativa o repositório multilib.
  sudo sed -i 's/^#\[multilib\]/[multilib]\nInclude = \/etc\/pacman.d\/mirrorlist/' /etc/pacman.conf
}

install_yay() {
  # Instala o Yay.
  cd $HOME/Downloads/
  sudo git clone https://aur.archlinux.org/yay.git
  sudo chmod 777 ./yay
  sudo chown -R $USER ./yay
  cd yay
  makepkg -si
  rm -rf $HOME/Downloads/yay
}

install_aur_packages() {
  # Instala pacotes AUR.
  yay -S --noconfirm visual-studio-code-bin steam spotify discord-canary ngrok postman-bin
}

configure_bluetooth() {
  # Configura o Bluetooth.
  sudo sed -i 's/#AutoEnable=true /AutoEnable=true /g' /etc/bluetooth/main.conf
  sudo systemctl enable --now bluetooth.service
}

install_xpadneo() {
    local repo_url="https://github.com/atar-axis/xpadneo.git"
    local target_dir="$HOME/Downloads/xpadneo"
    local max_attempts=10
    local attempt=1

    echo "Tentando clonar o repositório xpadneo em $target_dir..."
    while [ $attempt -le $max_attempts ]; do
        echo "Tentativa $attempt de $max_attempts..."
        if git clone "$repo_url" "$target_dir" 2>/dev/null; then
            if [ -d "$target_dir" ]; then
                echo "Repositório xpadneo clonado com sucesso na tentativa $attempt!"
                # Prossegue com os próximos passos
                cd "$target_dir" || {
                    echo "Erro: Não foi possível entrar no diretório $target_dir."
                    exit 1
                }
                echo "Executando o script de instalação..."
                if sudo ./install.sh; then
                    echo "Instalação concluída com sucesso!"
                    # Remove o diretório após a instalação
                    rm -rf "$target_dir"
                    echo "Diretório $target_dir removido."
                    return 0
                else
                    echo "Erro: Falha ao executar install.sh."
                    exit 1
                fi
            fi
        fi
        echo "Falha na tentativa $attempt. Tentando novamente em 5 segundos..."
        sleep 5
        # Remove o diretório caso tenha sido criado parcialmente
        [ -d "$target_dir" ] && rm -rf "$target_dir"
        attempt=$((attempt + 1))
    done

    echo "Erro: Não foi possível clonar o repositório $repo_url após $max_attempts tentativas."
    exit 1
}

configure_firewall() {
  # Configura o firewall.
  sudo systemctl enable ufw
  sudo systemctl start ufw
  sudo ufw enable
}

configure_docker() {
  # Ativa o serviço do Docker.
  sudo systemctl enable --now docker
  sudo usermod -aG docker $USER
}

install_nvm() {
  # Instala o NVM e o Node.js.
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
  nvm install node
}

configure_cronie() {
  # Ativa o serviço do cronie.
  sudo systemctl enable cronie.service
  sudo systemctl start cronie.service
}

configure_pacman() {
  # Configura o pacman para mostrar cores e aumenta o número de downloads simultâneos.
  sudo sed -i 's/#Color/Color/g' /etc/pacman.conf
  sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/g' /etc/pacman.conf
}

customize_mangohud() {
  # Cria o arquivo de configuração do MangoHud.
  mkdir -p $HOME/.config/MangoHud
  cat << EOF > $HOME/.config/MangoHud/MangoHud.conf
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

configure_flatpak() {
  # Adiciona o repositório beta do Flathub.
  flatpak remote-add --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
}

configure_rclone() {
  read -p "Deseja configurar o Rclone? [S/n]" resposta

  resposta=$(echo $resposta | tr 'a-z' 'A-Z')

  if [ "$resposta" == "S" ] || [ "$resposta" == "" ]; then
      mkdir $HOME/.mycloud

      rclone config
      mkdir -p $HOME/Documentos/Scripts/Logs

      # Cria o serviço de montagem do rclone.
      sudo cat << EOF > $HOME/rclone-mount.service
[Unit]
Description=Rclone Mount OneDrive
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/rclone mount OneDrive: $HOME/.mycloud \
    --log-file $HOME/Documentos/Scripts/Logs/rclone-mount.log \
    --vfs-cache-mode full \
    --vfs-cache-max-size 2G \
    --vfs-cache-max-age 10m \
    --rc \
    --rc-enable-metrics \
    --rc-web-gui \
    --no-console \
    --multi-thread-streams 32 \
    --rc-no-auth \
    --rc-web-gui-no-open-browser \
    --fast-list \
    --onedrive-chunk-size 25M \
    --use-mmap \
    --buffer-size 32M \
    --vfs-read-chunk-size 1M \
    --vfs-read-chunk-size-limit 128M
ExecStop=/bin/fusermount -uz $HOME/.mycloud
Restart=on-failure
User=$USER

[Install]
WantedBy=default.target
EOF
      # Cria o bisync.
      sudo cat << EOF > $HOME/rclone-bisync.service
[Unit]
Description=Sincronização bidirecional de pastas com OneDrive via Rclone
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/rclone bisync $HOME/Documentos OneDrive:/Documentos --max-delete 20000 --create-empty-src-dirs --compare size,modtime,checksum --slow-hash-sync-only --resilient -MvP --drive-skip-gdocs --fix-case
ExecStart=/usr/bin/rclone bisync $HOME/Downloads OneDrive:/Downloads --max-delete 20000 --create-empty-src-dirs --compare size,modtime,checksum --slow-hash-sync-only --resilient -MvP --drive-skip-gdocs --fix-case
ExecStart=/usr/bin/rclone bisync $HOME/Imagens OneDrive:/Imagens --max-delete 20000 --create-empty-src-dirs --compare size,modtime,checksum --slow-hash-sync-only --resilient -MvP --drive-skip-gdocs --fix-case
ExecStart=/usr/bin/rclone bisync $HOME/Vídeos OneDrive:/Vídeos --max-delete 20000 --create-empty-src-dirs --compare size,modtime,checksum --slow-hash-sync-only --resilient -MvP --drive-skip-gdocs --fix-case
ExecStart=/usr/bin/rclone bisync $HOME/Músicas OneDrive:/Músicas --max-delete 20000 --create-empty-src-dirs --compare size,modtime,checksum --slow-hash-sync-only --resilient -MvP --drive-skip-gdocs --fix-case
User=$USER
Nice=10
IOSchedulingClass=best-effort
IOSchedulingPriority=4

[Install]
WantedBy=multi-user.target
EOF

      # Cria o bisync resync.
      sudo cat << EOF > $HOME/rclone-bisync-resync.service
[Unit]
Description=Sincronização bidirecional de pastas com OneDrive via Rclone
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/rclone bisync $HOME/Documentos OneDrive:/Documentos --create-empty-src-dirs --compare size,modtime,checksum --slow-hash-sync-only --resilient -MvP --drive-skip-gdocs --fix-case --resync
ExecStart=/usr/bin/rclone bisync $HOME/Downloads OneDrive:/Downloads --create-empty-src-dirs --compare size,modtime,checksum --slow-hash-sync-only --resilient -MvP --drive-skip-gdocs --fix-case --resync
ExecStart=/usr/bin/rclone bisync $HOME/Imagens OneDrive:/Imagens --create-empty-src-dirs --compare size,modtime,checksum --slow-hash-sync-only --resilient -MvP --drive-skip-gdocs --fix-case --resync
ExecStart=/usr/bin/rclone bisync $HOME/Vídeos OneDrive:/Vídeos --create-empty-src-dirs --compare size,modtime,checksum --slow-hash-sync-only --resilient -MvP --drive-skip-gdocs --fix-case --resync
ExecStart=/usr/bin/rclone bisync $HOME/Músicas OneDrive:/Músicas --create-empty-src-dirs --compare size,modtime,checksum --slow-hash-sync-only --resilient -MvP --drive-skip-gdocs --fix-case --resync
User=$USER
Nice=10
IOSchedulingClass=best-effort
IOSchedulingPriority=4

[Install]
WantedBy=multi-user.target
EOF
      # Cria o gatilho para o bisync.
      sudo cat << EOF > $HOME/rclone-bisync.timer
[Unit]
Description=Executa a sincronização bidirecional do Rclone periodicamente

[Timer]
OnBootSec=5min
OnUnitActiveSec=15min
Unit=rclone-bisync.service

[Install]
WantedBy=timers.target
EOF

      # Cria os serviços e ativa-os.
      sudo mv $HOME/rclone-mount.service /etc/systemd/system/
      sudo mv $HOME/rclone-bisync.service /etc/systemd/system/
      sudo mv $HOME/rclone-bisync-resync.service /etc/systemd/system/
      sudo mv $HOME/rclone-bisync.timer /etc/systemd/system/
      sudo systemctl daemon-reload
      sudo systemctl enable --now rclone-mount.service
      sleep 10

      # Sincroniza as pastas da nuvem com o computador.
      sudo systemctl start rclone-bisync-resync.service
      
      # Ativa o serviço gatilho para o bisync.
      sudo systemctl enable --now rclone-bisync.timer
  else
      echo "Você escolheu não instalar e configurar o rclone."
  fi
}

main() {
  enable_systemd-resolved
  enable_multilib
  update_system
  remove_unnecessary_apps
  install_packages
  configure_zsh
  install_yay
  install_aur_packages
  configure_bluetooth
  configure_firewall
  configure_docker
  install_nvm
  configure_cronie
  configure_pacman
  configure_flatpak
  customize_mangohud
  configure_rclone
  install_xpadneo

  echo 'Configuração finalizada.'
}

if [ "$EUID" -eq 0 ]; then
  echo "Por favor, não execute este script como root."
  exit 1
fi

main