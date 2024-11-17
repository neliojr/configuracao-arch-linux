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
rm ~/.bashrc
cat << EOF > ~/.bashrc
#
# ~/.bashrc
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
    mkdir -p ~/Documentos/Scripts/Logs

    #Configurando serviço para montar o OneDrive com o systemctl
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

    #Baixando pastas do OneDrive para o /home/user
    mkdir ~/.mycloud
    rclone sync OneDrive:/Documentos ~/Documentos --progress
    rclone sync OneDrive:/Downloads ~/Downloads --progress
    rclone sync OneDrive:/Imagens ~/Imagens --progress
    rclone sync OneDrive:/Vídeos ~/Vídeos --progress

    #Adicionando cron
    (crontab -l; echo "*/15 * * * * ~/Documentos/Scripts/rclone-sync.sh") | crontab -
    chmod +x ~/Documentos/Scripts/rclone-sync.sh
else
    echo "Você escolheu não instalar e configurar o rclone."
fi

#Instalando apps
sudo pacman -S --noconfirm vlc putty gnome-browser-connector flatpak git cronie

#Configurando git
git config --global user.name "Nelio Júnior"
git config --global user.email neliojr@neliojr.me

#Baixando e instalando xpadneo (driver do controle xbox)
git clone https://github.com/atar-axis/xpadneo.git ~/Downloads/xpadneo
sudo pacman -S --noconfirm dkms linux-headers
cd ~/Downloads/xpadneo
sudo ./install.sh

#Flatpaks
flatpak install --assumeyes flathub org.telegram.desktop
flatpak install --assumeyes flathub dev.vencord.Vesktop
flatpak install --assumeyes flathub com.spotify.Client
flatpak install --assumeyes flathub com.valvesoftware.Steam
flatpak install --assumeyes flathub org.gnome.Boxes
flatpak install --assumeyes flathub net.lutris.Lutris
flatpak install --assumeyes flathub org.gimp.GIMP
flatpak install --assumeyes flathub org.inkscape.Inkscape
flatpak install --assumeyes flathub com.getpostman.Postman
flatpak install --assumeyes flathub org.mozilla.Thunderbird
flatpak install --assumeyes flathub com.visualstudio.code
flatpak install --assumeyes flathub net.agalwood.Motrix
flatpak install --assumeyes flathub com.obsproject.Studio
flatpak install --assumeyes flathub io.github.brunofin.Cohesion
flatpak install --assumeyes flathub it.mijorus.gearlever

#NVM
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
nvm install node

echo 'Configuração finalizada.'