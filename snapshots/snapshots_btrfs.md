# Como gerenciar snapshots com BTRFS
## Criando uma snapshot
Para criar uma snapshot utilize o comando:  
`sudo btrfs subvolume snapshot -r / /.snapshots/@snapshot-home-$(date +%Y%m%d-%H%M%S)-"Descrição da snapshot"`  
Esse comando criará uma snapshot da raiz "/"  

## Apagando uma snapshot
Caso deseje remover uma snapshot, utilize:  
`sudo btrfs subvolume delete caminho/do/backup`  


## Listando todas snapshots
Para listar todas as snapshots, utilize:  
`sudo btrfs subvolume list -t /`