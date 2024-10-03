# Sincronizar com Rsync
Acesse o terminal vá para o arquivo do crontab:  
`export EDITOR=nano`  
`crontab -e`  

No final do arquivo, coloque o cron (exemplo):  
`*/15 * * * * ~/Documentos/Scripts/rclone-sync.sh >> ~/Documentos/Scripts/logs/rclone-sync.log 2>&1`

O cron será executado a cada 15 minutos.

Script que está sendo executado: `sync-with-rsync.sh`  
```
#!/bin/bash
/usr/bin/rclone sync ~/Documentos OneDrive:/Documentos --progress
/usr/bin/rclone sync ~/Downloads OneDrive:/Downloads --progress
/usr/bin/rclone sync ~/Imagens OneDrive:/Imagens --progress
/usr/bin/rclone sync ~/Vídeos OneDrive:/Vídeos --progress
```