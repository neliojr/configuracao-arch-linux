# Instalando ProtonVPN
Baixe o repositório:  
`wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.4_all.deb`

Instale o arquivo .deb:  
`sudo dpkg -i ./protonvpn-stable-release_1.0.4_all.deb`

Atualize os pacotes no apt-get:  
`sudo apt update`

Instale o app com o apt-get:  
`sudo apt install proton-vpn-gnome-desktop`

## Instalando ícone de bandeja
Digite o comando:  
`sudo apt install libayatana-appindicator3-1 gir1.2-ayatanaappindicator3-0.1 gnome-shell-extension-appindicator`