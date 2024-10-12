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

#Instalando apps
sudo pacman -S --noconfirm vlc putty gnome-browser-connector flatpak git cronie
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
flatpak install --assumeyes flathub io.github.brunofin.Cohesion
#NVM
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
nvm install node

#Configurando apps
#Git
git config --global user.name "Nelio Júnior"
git config --global user.email neliojr@neliojr.me
#Cronie
sudo systemctl enable cronie.service
sudo systemctl start cronie.service

#Personalização
#Alterando cor do usuário no terminal
sed -i 's/^PS1=.*/PS1='\''\\\[\\033[01;32m\\\]\\u@\\h\\\[\\033[00m\\\]:\\\[\\033[01;32m\\\]\\W\\\[\\033[00m\\\]\$ '\''/' ~/.bashrc
#Ativando cor no pacman.
sudo sed -i 's/#Color/Color/g' /etc/pacman.conf
#Alterando quantidade de downloads paralelos
sudo sed -i 's/ParallelDownloads = 5/ParallelDownloads = 10/g' /etc/pacman.conf

#Baixando e instalando xpadneo (driver do controle xbox)
git clone https://github.com/atar-axis/xpadneo.git ~/Downloads/xpadneo
sudo pacman -S dkms linux-headers
cd ~/Downloads
sudo ./install.sh

echo 'Configuração finalizada.'