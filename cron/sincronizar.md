# Sincronizar com Rsync
Acesse o terminal vá para o arquivo do crontab:  
`crontab -e`

No final do arquivo, coloque o cron (exemplo):  
`*/15 * * * * /home/nelio/Documentos/Scripts/sync-with-rsync.sh >> /home/nelio/Documentos/Scripts/logs/log-cron.txt 2>&1`

O cron será executado a cada 15 minutos.

Script que está sendo executado: `sync-with-rsync.sh`  
`/usr/bin/rsync -av --delete /home/nelio/Documentos/ /home/nelio/.onedrive/Documentos`  
`/usr/bin/rsync -av --delete /home/nelio/Imagens/ /home/nelio/.onedrive/Imagens`  
`/usr/bin/rsync -av --delete /home/nelio/Downloads/ /home/nelio/.onedrive/Downloads`  
`/usr/bin/rsync -av --delete /home/nelio/Vídeos/ /home/nelio/.onedrive/Vídeos`