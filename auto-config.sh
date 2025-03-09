#!/bin/bash
clear
echo 'NÃO EXECUTE ESTE SCRIPT COMO ROOT!!!'
echo 'Iniciando configuração do sistema em 10s.'
echo 'Pressione CTRL + C para cancelar.'
sleep 10

# Atualizando repositório
sudo pacman -Syu --noconfirm

# Instalando pacotes
sudo pacman -S --noconfirm bluez bluez-utils bluez-tools blueman rclone mangohud ufw dkms linux-headers neofetch lutris wget git timeshift fuse2 jdk-openjdk vlc ncdu putty docker docker-compose croc gnome-browser-connector flatpak cronie gnome-boxes

# Ativando o multilib
sudo sed -i 's/^#\[multilib\]/[multilib]\nInclude = \/etc\/pacman.d\/mirrorlist/' /etc/pacman.conf

# Atualizando repositório
sudo pacman -Syu --noconfirm

# Instalando yay (AUR helper)
cd /home/nelio/Downloads/
sudo git clone https://aur.archlinux.org/yay.git
sudo chmod 777 ./yay
sudo chown -R $USER ./yay
cd yay
makepkg -si

# Instalando Visual Studio Code e Steam pelo yay
yay -S --noconfirm visual-studio-code-bin steam ngrok

# Desinstalando apps desnecessários.
sudo pacman -R --noconfirm gnome-music gnome-tour gnome-weather gnome-maps gnome-contacts gnome-calendar gnome-clocks snapshot totem epiphany simple-scan

# Configurando bluetooth
sudo sed -i 's/#AutoEnable=true /AutoEnable=true /g' /etc/bluetooth/main.conf
sudo systemctl start bluetooth.service
sudo systemctl enable bluetooth.service

# Baixando e instalando xpadneo (driver do controle xbox)
git clone https://github.com/atar-axis/xpadneo.git /home/nelio/Downloads/xpadneo
cd /home/nelio/Downloads/xpadneo
sudo ./install.sh

# Configurando firewall
sudo systemctl enable ufw
sudo systemctl start ufw
sudo ufw enable

# Confgurando docker
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# Configurando git
git config --global user.name "Nelio Júnior"
git config --global user.email neliojr@neliojr.me

# Instalando NVM
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
nvm install node

# Configurando apps
# Cronie
sudo systemctl enable cronie.service
sudo systemctl start cronie.service

# Personalização
# Alterando cor do usuário no terminal
rm /home/nelio/.bashrc
cat << EOF > /home/nelio/.bashrc
#
# /home/nelio/.bashrc
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
sudo ln -sf /home/nelio/.bashrc /root/.bashrc

# Ativando cor no pacman.
sudo sed -i 's/#Color/Color/g' /etc/pacman.conf

# Alterando quantidade de downloads paralelos
sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/g' /etc/pacman.conf

# Ativando repositório beta do flatpak
flatpak remote-add --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo

# Configurando OneDrive com Rclone
read -p "Deseja configurar o Rclone? [S/n]" resposta

resposta=$(echo $resposta | tr 'a-z' 'A-Z')

if [ "$resposta" == "S" ] || [ "$resposta" == "" ]; then
    rclone config
    mkdir -p /home/nelio/Documentos/Scripts/Logs

    # Configurando serviço para montar o OneDrive com o systemctl
    # Montador do cloud.
    sudo su
    sudo cat << EOF > /etc/systemd/system/rclone-mount.service
[Unit]
Description=Rclone Mount OneDrive
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/rclone mount OneDrive: /home/nelio/.mycloud \
    --log-file /home/nelio/Documentos/Scripts/Logs/rclone-mount.log \
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
ExecStop=/bin/fusermount -uz /home/nelio/.mycloud
Restart=on-failure
User=nelio

[Install]
WantedBy=default.target
EOF
    # Sincronizador.
    sudo cat << EOF > /etc/systemd/system/rclone-sync.service
[Unit]
Description=Sincronização de pastas com OneDrive via Rclone
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/rclone sync /home/nelio/Documentos OneDrive:/Documentos --progress
ExecStart=/usr/bin/rclone sync /home/nelio/Downloads OneDrive:/Downloads --progress
ExecStart=/usr/bin/rclone sync /home/nelio/Imagens OneDrive:/Imagens --progress
ExecStart=/usr/bin/rclone sync /home/nelio/Vídeos OneDrive:/Videos --progress
User=nelio
Nice=10
IOSchedulingClass=best-effort
IOSchedulingPriority=4

[Install]
WantedBy=multi-user.target
EOF

    # Timer do sincronizador.
    sudo cat << EOF > /etc/systemd/system/rclone-sync.timer
[Unit]
Description=Executa a sincronização do Rclone periodicamente

[Timer]
OnBootSec=5min
OnUnitActiveSec=15min
Unit=rclone-sync.service

[Install]
WantedBy=timers.target
EOF
    exit
    sudo systemctl daemon-reload
    sudo systemctl enable --now rclone-sync.timer
    sudo systemctl enable rclone-mount.service
    sudo systemctl start rclone-mount.service

    # Baixando pastas do OneDrive para o /home/user
    mkdir /home/nelio/.mycloud
    rclone sync OneDrive:/Documentos /home/nelio/Documentos --progress
    rclone sync OneDrive:/Downloads /home/nelio/Downloads --progress
    rclone sync OneDrive:/Imagens /home/nelio/Imagens --progress
    rclone sync OneDrive:/Videos /home/nelio/Vídeos --progress
else
    echo "Você escolheu não instalar e configurar o rclone."
fi

# Instalando flatpaks
flatpak install --assumeyes flathub org.telegram.desktop
flatpak install --assumeyes flathub com.discordapp.DiscordCanary
flatpak install --assumeyes flathub com.bitwarden.desktop
flatpak install --assumeyes flathub com.spotify.Client
flatpak install --assumeyes flathub org.gimp.GIMP
flatpak install --assumeyes flathub org.inkscape.Inkscape
flatpak install --assumeyes flathub com.getpostman.Postman
flatpak install --assumeyes flathub org.mozilla.Thunderbird
flatpak install --assumeyes flathub de.haeckerfelix.Fragments
flatpak install --assumeyes flathub io.dbeaver.DBeaverCommunity
flatpak install --assumeyes flathub org.audacityteam.Audacity
flatpak install --assumeyes flathub org.libreoffice.LibreOffice

echo 'Configuração finalizada.'