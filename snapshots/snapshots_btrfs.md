# Como gerenciar snapshots com BTRFS
## Instalando pacotes necessários
Instale os seguintes pacotes para gerenciar as snapshots e adicionar o menu de snapshots ao GRUB:  
```bash
sudo pacman -S grub-btrfs inotify-tools timeshift
```  
Você poderá gerenciar as snapshots pela GUI do timeshift.

Regenere o script do GRUB:  
```bash
grub-mkconfig -o /boot/grub/grub.cfg
``` 

## Ativando serviço
Para colocar automaticamente as snapshots ao menu do GRUB, ative o serviço do grub-btrfsd:  
```bash
sudo systemctl edit grub-btrfsd
```  

Após os comentários adicione:  
```bash
[Service]
ExecStart=/usr/bin/grub-btrfsd --syslog --timeshift-auto
```  

Recarregue os serviços:  
```bash
sudo systemctl daemon-reload
```

Ative o serviço do grub-btrfsd:  
```bash
sudo systemctl enable —now grub-btrfsd
```