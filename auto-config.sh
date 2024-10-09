#!/bin/bash

#Atualizando repositório
sudo pacman -Syu

#Instalando drivers
sudo pacman -S --noconfirm bluez bluez-utils bluez-tools blueman
#abrir config e alterar o # do AutoEnable=true
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