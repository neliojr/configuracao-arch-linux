#!/bin/bash
clear
echo 'Iniciando configuração do sistema em 10s.'
echo 'Pressione CTRL + C para cancelar.'
sleep 10

#Atualizando repositório
sudo pacman -Syu

#Instalando drivers
sudo pacman -S --noconfirm bluez bluez-utils bluez-tools blueman
sudo sed -i 's/#AutoEnable=true /AutoEnable=true /g' /etc/bluetooth/main.conf
sudo systemctl start bluetooth.service
sudo systemctl enable bluetooth.service

#Desinstalando apps desnecessários.
sudo pacman -R --noconfirm gnome-music gnome-tour gnome-weather gnome-maps gnome-contacts gnome-calendar gnome-clocks snapshot totem epiphany simple-scan

#Instalando firewall
sudo pacman -S --noconfirm ufw
sudo systemctl enable ufw
sudo systemctl start ufw
sudo ufw enable

#Configurando apps
#Cronie
sudo systemctl enable cronie.service
sudo systemctl start cronie.service

#Personalização
#Alterando cor do usuário no terminal
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
#Ativando cor no pacman.
sudo sed -i 's/#Color/Color/g' /etc/pacman.conf
#Alterando quantidade de downloads paralelos
sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/g' /etc/pacman.conf

#Configurando OneDrive com Rclone
read -p "Deseja instalar e configurar o Rclone? [S/n]" resposta

resposta=$(echo $resposta | tr 'a-z' 'A-Z')

if [ "$resposta" == "S" ] || [ "$resposta" == "" ]; then
    sudo pacman -S --noconfirm rclone
    rclone config
    mkdir -p /home/nelio/Documentos/Scripts/Logs

    #Configurando serviço para montar o OneDrive com o systemctl
    #Montador do cloud.
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
Group=nelio

[Install]
WantedBy=default.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable rclone-mount.service
    sudo systemctl start rclone-mount.service

    #Sincronizador.
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
Group=nelio
Nice=10
IOSchedulingClass=best-effort
IOSchedulingPriority=4

[Install]
WantedBy=multi-user.target
EOF

    #Timer do sincronizador.
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
    sudo systemctl daemon-reload
    sudo systemctl enable --now rclone-sync.timer

    #Baixando pastas do OneDrive para o /home/user
    mkdir /home/nelio/.mycloud
    rclone sync OneDrive:/Documentos /home/nelio/Documentos --progress
    rclone sync OneDrive:/Downloads /home/nelio/Downloads --progress
    rclone sync OneDrive:/Imagens /home/nelio/Imagens --progress
    rclone sync OneDrive:/Videos /home/nelio/Vídeos --progress
else
    echo "Você escolheu não instalar e configurar o rclone."
fi

#Instalando apps
sudo pacman -S --noconfirm vlc putty docker docker-compose crock git gnome-browser-connector flatpak cronie gnome-boxes

#Confgurando docker
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

#Configurando git
git config --global user.name "Nelio Júnior"
git config --global user.email neliojr@neliojr.me

#Baixando e instalando xpadneo (driver do controle xbox)
git clone https://github.com/atar-axis/xpadneo.git /home/nelio/Downloads/xpadneo
sudo pacman -S --noconfirm dkms linux-headers
cd /home/nelio/Downloads/xpadneo
sudo ./install.sh

#Ativando repositório beta do flatpak
flatpak remote-add --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo

#Flatpaks
flatpak install --assumeyes flathub org.telegram.desktop
flatpak install --assumeyes flathub com.discordapp.DiscordCanary
flatpak install --assumeyes flathub com.bitwarden.desktop
flatpak install --assumeyes flathub com.spotify.Client
flatpak install --assumeyes flathub com.valvesoftware.Steam
flatpak install --assumeyes flathub net.lutris.Lutris
flatpak install --assumeyes flathub org.gimp.GIMP
flatpak install --assumeyes flathub org.inkscape.Inkscape
flatpak install --assumeyes flathub com.getpostman.Postman
flatpak install --assumeyes flathub org.mozilla.Thunderbird
flatpak install --assumeyes flathub org.qbittorrent.qBittorrent
flatpak install --assumeyes flathub com.visualstudio.code
flatpak install --assumeyes flathub io.dbeaver.DBeaverCommunity

#NVM
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
nvm install node

echo 'Configuração finalizada.'