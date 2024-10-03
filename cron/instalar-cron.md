# Instalar Cron
Para instalar o cron baixe o pacote com o pacman:  
`sudo pacman -S cronie`  

Agora ative o cron para iniciar com o sistema:  
`sudo systemctl enable cronie.service`  

Inicie o cron:  
`sudo systemctl start cronie.service`
