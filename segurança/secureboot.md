# Ativando secureboot
Baixe o sbctl:  
`sudo pacman -S sbctl`

Certifique-se que o secureboot está no modo setup:  
`sbctl status`

Gere as chaves:  
`sudo sbctl create-keys`

Verifique quais arquivos precisam de assinatura:  
`sudo sbctl verify`

Assine todos os arquivos:  
`sudo sbctl sign -s (diretório)`