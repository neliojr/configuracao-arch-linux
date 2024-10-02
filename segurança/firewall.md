# Instalando firewall (ufw)
instale o ufw:  
`sudo pacman -S ufw`  

configure o ufw para iniciar com o sistema:  
`sudo systemctl enable ufw`  

inicie o ufw:  
`sudo systemctl start ufw`  

ative o ufw:  
`sudo ufw enable`  

verifique se está ativo:  
`sudo ufw status`