# Tutorial de Instalação do Arch Linux com GNOME ou KDE

Este tutorial ensina a instalação do Arch Linux com a interface gráfica GNOME ou KDE, usando o sistema de arquivos Btrfs e configurando a rede de maneira otimizada.

## 1. Testando a Internet
Para verificar a conectividade, use o comando:

```bash
ping -c 4 skwren.com
```

## 2. Configuração do Disco

### Listar as Partições
```bash
fdisk -l
```

### Particionar o Disco
Execute o comando para particionar o disco:

```bash
cfdisk /dev/sda
```

Escolha o esquema de partição **GPT** e crie as seguintes partições:

1. **Partição 1 (EFI System)**: 1GB, para o `/boot/efi`
2. **Partição 2 (Linux swap)**, para o swap
3. **Partição 3 (Linux filesystem)**, para a raiz `/`

Após criar as partições, salve e saia.

### Formatando as Partições

- **Partição de Boot (EFI)**: 
  ```bash
  mkfs.fat -F32 /dev/sda1
  ```

- **Partição Swap**: 
  ```bash
  mkswap /dev/sda2
  ```

- **Partição Raiz (Sistema)**: 
  ```bash
  mkfs.btrfs /dev/sda3
  ```

## 3. Pontos de Montagem

Monte as partições conforme abaixo:

- **Partição Raiz**: 
  ```bash
  mount /dev/sda3 /mnt
  ```

- **Criando os subvolumes com Btrfs**:
  ```bash
  btrfs subvolume create /mnt/@
  btrfs subvolume create /mnt/@home
  btrfs subvolume create /mnt/@log
  btrfs subvolume create /mnt/@cache
  ```

- **Desmonte a raiz**:
  ```bash
  umount /mnt

- **Montando as Partições e Subvolumes**:
  - Partição **raiz**:
    ```bash
    mount -o relatime,compress=zstd,subvol=@ /dev/sda3 /mnt
    ```

  - Criando diretórios na **raiz**:
    ```bash
    mkdir -p /mnt/{home,var/log,var/cache,boot/efi}
    ```

  - Subvolume **/home**:
    ```bash
    mount -o relatime,compress=zstd,subvol=@home /dev/sda3 /mnt/home
    ```

  - Subvolume **/var/log**:
    ```bash
    mount -o relatime,compress=zstd,subvol=@log /dev/sda3 /mnt/var/log
    ```

  - Subvolume **/var/cache**:
    ```bash
    mount -o relatime,compress=zstd,subvol=@cache /dev/sda3 /mnt/var/cache
    ```

  - Partição **/boot/efi**:
    ```bash
    mount /dev/sda1 /mnt/boot/efi
    ```

- **Ativando o Swap**:
  ```bash
  swapon /dev/sda2
  ```

Verifique se está tudo correto com o comando:

```bash
lsblk
```

## 4. Configurando Espelhos

Atualize os espelhos com o Reflector:

```bash
sudo reflector --country "Brazil" --latest 20 --sort rate --save /etc/pacman.d/mirrorlist
```

## 5. Instalando Pacotes Essenciais

Instale os pacotes básicos do Arch:

```bash
pacstrap /mnt base base-devel linux linux-firmware nano vim dhcpcd
```

## 6. Gerando a Tabela FSTAB

Crie o arquivo `fstab`:

```bash
genfstab -U -p /mnt >> /mnt/etc/fstab
```

Verifique se o arquivo foi gerado corretamente:

```bash
cat /mnt/etc/fstab
```

## 7. Acessando o Sistema no Chroot

Acesse o sistema com `arch-chroot`:

```bash
arch-chroot /mnt
```

## 8. Configurando Data e Hora

Defina o fuso horário de Brasília:

```bash
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
```

Sincronize o relógio:

```bash
hwclock --systohc
```

Verifique a hora:

```bash
date
```

## 9. Alterando o Idioma do Sistema

- Edite o arquivo `locale.gen` e descomente as linhas:

```bash
nano /etc/locale.gen
```

Descomente as linhas:

```
pt_BR.UTF-8 UTF-8
pt_BR ISO-8859-1
```

- Gere as localizações:

```bash
locale-gen
```

- Configure o hostname:

```bash
hostnamectl set-hostname nomedoseuhost
```

## 10. Criando o Usuário

- Crie a senha do root:

```bash
passwd
```

- Crie o usuário com permissões de `wheel`, `storage` e `power`:

```bash
useradd -m -g users -G wheel,storage,power -s /bin/bash nomedousuario
```

- Defina a senha do usuário:

```bash
passwd nomedousuario
```

## 11. Instalando Pacotes Úteis

Instale pacotes adicionais:

```bash
pacman -S dosfstools mtools network-manager-applet networkmanager dialog
```

## 12. Instalando o GRUB

Instale o GRUB e o gerenciador de inicialização:

```bash
pacman -S grub efibootmgr
```

- Instale o GRUB para UEFI:

```bash
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch_grub --recheck
```

- Crie o arquivo de configuração do GRUB:

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

Saia do chroot:

```bash
exit
```

Reinicie o sistema:

```bash
reboot
```

## 13. Adicionando o Usuário ao Arquivo Sudoers

Adicione o usuário ao grupo `wheel`:

```bash
su -
EDITOR=nano visudo
```

Descomente a linha:

```
%wheel ALL=(ALL:ALL) ALL
```

Salve e saia. Saia do root:

```bash
exit
```

## 14. Conectando à Internet

Ative a rede com:

```bash
sudo dhcpcd
```

Ative o serviço do NetworkManager:

```bash
systemctl enable NetworkManager
```

Teste a conexão:

```bash
ping -c 4 skwren.com
```

## 15. Instalando a Interface Gráfica

### Instalando os Drivers AMD

```bash
sudo pacman -S xf86-video-amdgpu
```

<details>
  <summary><b>Instalando o GNOME</b></summary>

```bash
sudo pacman -S gnome
```

Ative o serviço:

```bash
systemctl enable gdm
```
</details>

<details>
  <summary><b>Instalando o KDE Plasma</b></summary>

```bash
sudo pacman -S plasma konsole
```

Ative o serviço:

```bash
systemctl enable sddm
```
</details>

Reinicie o sistema:

```bash
reboot
```