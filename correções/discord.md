# Arrumando bug do compartilhamento de tela no discord

Digitar esse comando no terminal para editar o arquivo: `sudo nano /etc/gdm3/custom.conf`
Procure por: `#WaylandEnable=false` e remova o # da linha para tirar o comentário.