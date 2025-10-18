# Ativando secureboot
Baixe o sbctl:  
```bash
sudo pacman -S sbctl
```

Certifique-se que o secureboot está no modo setup:  

```bash
sbctl status
```

Gere as chaves:  

```bash
sudo sbctl create-keys
```

Verifique quais arquivos precisam de assinatura:  

```bash
sudo sbctl verify
```

Assine todos os arquivos:  

```bash
sudo sbctl sign -s (diretório)
```

Verifique se todos os arquivos estão assinados:  

```bash
sudo sbctl verify
```