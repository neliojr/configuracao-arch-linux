# Personalizando terminal
### Cor do user do bash no terminal:  
acesse o arquivo de configuração  
`nano ~/.bashrc`  

altere o PS1 para:  
`PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;32m\]\w\[\033[00m\]$ '`  
sudo:  
`PS1='\[\033[01;95m\]\u@\h\[\033[00m\]:\[\033[01;95m\]\w\[\033[00m\]# '`