# Como montar disco NTFS
Plugue o pendrive
Instale a extensão para interpretar o formato de arquivo NTFS:  
`sudo apt-get install ntfs-3g`

Verifique as partições e procure o nome.

Monte a partição (exemplo):  
`sudo mount -t ntfs-3g /dev/sdc1 ~/Downloads/MedicatUSB`