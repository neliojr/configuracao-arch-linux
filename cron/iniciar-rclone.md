# Iniciar Rclone
Acesse o terminal vá para o arquivo do crontab:  
`export EDITOR=nano`
`crontab -e`

No final do arquivo, coloque o cron (exemplo):  
`@reboot ~/Documentos/Scripts/rclone-mount.sh`

Script que está sendo executado: `rclone-mount.sh`  
```
#!/bin/bash
/usr/bin/fusermount -u ~/.mycloud
/usr/bin/sleep 15
/usr/bin/rclone mount OneDrive: ~/.mycloud --log-file ~/Documentos/Scripts/Logs/rclone-mount.log --vfs-cache-mode full --vfs-cache-max-size 2G --vfs-cache-max-age 10m --rc --rc-enable-metrics --rc-web-gui --no-console --multi-thread-streams 32 --rc-no-auth --rc-web-gui-no-open-browser --fast-list --onedrive-chunk-size 25M --use-mmap --buffer-size 32M --vfs-read-chunk-size 1M --vfs-read-chunk-size-limit 128M
```
