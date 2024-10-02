# Instalando bluetooth no ArchLinux:  
instalar drivers:  
`sudo pacman -S bluez bluez-utils bluez-tools blueman `  

abra o arquivo de configuração:  
`sudo nano /etc/bluetooth/main.conf`  

procure a linha #AutoEnable=true e tire o comentário.  

inicie o processo:  
`sudo systemctl start bluetooth.service`

configure o processo para iniciar com o sistema:  
`sudo systemctl enable bluetooth.service `