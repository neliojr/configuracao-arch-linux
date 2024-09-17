# Iniciar Rclone
Acesse o terminal vá para o arquivo do crontab:  
`crontab -e`

No final do arquivo, coloque o cron (exemplo):  
`@reboot /home/nelio/Documentos/Scripts/start-rclone.sh`

Script que está sendo executado: `start-rclone.sh`  
`/usr/bin/fusermount -u /home/nelio/.onedrive`  
`/usr/bin/sleep 15`  
`/usr/bin/rclone mount OneDrive: /home/nelio/.onedrive --log-file /home/nelio/Documentos/Scripts/logs/log-rclone.txt --vfs-cache-mode full --vfs-cache-max-size 2G --vfs-cache-max-age 10m --rc --rc-enable-metrics --rc-web-gui --no-console --multi-thread-streams 32 --rc-no-auth --rc-web-gui-no-open-browser --fast-list --onedrive-chunk-size 25M --use-mmap --buffer-size 32M --vfs-read-chunk-size 1M --vfs-read-chunk-size-limit 128M`