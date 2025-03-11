update_system() {
  # Atualiza o sistema.
  sudo pacman -Syu --noconfirm
}

remove_unnecessary_apps() {
  # Remove aplicativos desnecessários.
  sudo pacman -R --noconfirm gnome-music gnome-tour gnome-weather gnome-maps gnome-contacts gnome-calendar gnome-clocks snapshot totem epiphany simple-scan
}

install_packages() {
  # Instala pacotes do sistema.
  sudo pacman -S --noconfirm bluez bluez-utils bluez-tools blueman rclone mangohud ufw dkms linux-headers neofetch lutris bitwarden telegram-desktop thunderbird gimp inkscape qbittorrent audacity wget git timeshift fuse2 jdk-openjdk vlc ncdu putty docker docker-compose croc gnome-browser-connector flatpak cronie gnome-boxes
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
  sudo systemctl start bluetooth.service
  sudo systemctl enable bluetooth.service
}

install_xpadneo() {
  # Instala o driver xpadneo para o controle do Xbox.
  git clone https://github.com/atar-axis/xpadneo.git $HOME/Downloads/xpadneo
  cd $HOME/Downloads/xpadneo
  sudo ./install.sh
  rm -rf $HOME/Downloads/xpadneo
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
  wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
  nvm install node
}

configure_cronie() {
  # Ativa o serviço do cronie.
  sudo systemctl enable cronie.service
  sudo systemctl start cronie.service
}

customize_terminal() {
  # Adiciona cor ao bash no terminal.
  rm $HOME/.bashrc
  cat << EOF > $HOME/.bashrc
#
# $HOME/.bashrc
#

# If not running interactively, don't do anything
[[ \$- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
export EDITOR=nano

# Prompt color.
if [[ \$EUID == 0 ]]; then
    PS1='\[\033[01;95m\]\u@\h\[\033[00m\]:\[\033[01;95m\]\w\[\033[00m\]# '
else
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;32m\]\w\[\033[00m\]$ '
fi
EOF
  sudo ln -sf $HOME/.bashrc /root/.bashrc
}

configure_pacman() {
  # Configura o pacman para mostrar cores e aumenta o número de downloads simultâneos.
  sudo sed -i 's/#Color/Color/g' /etc/pacman.conf
  sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/g' /etc/pacman.conf
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
ExecStart=/usr/bin/rclone bisync $HOME/Documentos OneDrive:/Documentos --create-empty-src-dirs --compare size,modtime,checksum --slow-hash-sync-only --resilient -MvP --drive-skip-gdocs --fix-case
ExecStart=/usr/bin/rclone bisync $HOME/Downloads OneDrive:/Downloads --create-empty-src-dirs --compare size,modtime,checksum --slow-hash-sync-only --resilient -MvP --drive-skip-gdocs --fix-case
ExecStart=/usr/bin/rclone bisync $HOME/Imagens OneDrive:/Imagens --create-empty-src-dirs --compare size,modtime,checksum --slow-hash-sync-only --resilient -MvP --drive-skip-gdocs --fix-case
ExecStart=/usr/bin/rclone bisync $HOME/Vídeos OneDrive:/Vídeos --create-empty-src-dirs --compare size,modtime,checksum --slow-hash-sync-only --resilient -MvP --drive-skip-gdocs --fix-case
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
      sudo mv $HOME/rclone-bisync.timer /etc/systemd/system/
      sudo systemctl daemon-reload
      sudo systemctl enable rclone-mount.service
      sudo systemctl start rclone-mount.service
      sleep 10

      # Sincroniza as pastas da nuvem com o computador.
      rclone bisync /home/nelio/Documentos OneDrive:/Documentos --create-empty-src-dirs --compare size,modtime,checksum --slow-hash-sync-only --resilient -MvP --drive-skip-gdocs --fix-case --resync
      rclone bisync /home/nelio/Downloads OneDrive:/Downloads --create-empty-src-dirs --compare size,modtime,checksum --slow-hash-sync-only --resilient -MvP --drive-skip-gdocs --fix-case --resync
      rclone bisync /home/nelio/Imagens OneDrive:/Imagens --create-empty-src-dirs --compare size,modtime,checksum --slow-hash-sync-only --resilient -MvP --drive-skip-gdocs --fix-case --resync
      rclone bisync /home/nelio/Vídeos OneDrive:/Vídeos --create-empty-src-dirs --compare size,modtime,checksum --slow-hash-sync-only --resilient -MvP --drive-skip-gdocs --fix-case --resync
      
      # Ativa o serviço gatilho para o bisync.
      sudo systemctl enable --now rclone-bisync.timer
  else
      echo "Você escolheu não instalar e configurar o rclone."
  fi
}

main() {
  update_system
  remove_unnecessary_apps
  install_packages
  enable_multilib
  update_system
  install_yay
  install_aur_packages
  configure_bluetooth
  install_xpadneo
  configure_firewall
  configure_docker
  install_nvm
  configure_cronie
  customize_terminal
  configure_pacman
  configure_flatpak
  configure_rclone

  echo 'Configuração finalizada.'
}

if [ "$EUID" -eq 0 ]; then
  echo "Por favor, não execute este script como root."
  exit 1
fi

main