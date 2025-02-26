# Como gerenciar snapshots com BTRFS
## Criando uma snapshot
Para criar uma snapshot utilize o comando:  
`sudo timeshift --create --comment "descrição"`  
Esse comando criará uma snapshot da raiz "/"  

## Apagando uma snapshot
Caso deseje remover uma snapshot, utilize:  
`sudo timeshift --delete --snapshot "nome"`  


## Listando todas snapshots
Para listar todas as snapshots, utilize:  
`sudo timeshift --list`