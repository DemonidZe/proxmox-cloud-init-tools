# Proxmox cloud-init tools
ShellScript tools to deploy VM cloud-init in Proxmox Virtual Environment (PVE)

### Supported PVE Versions
- PVE 6 *Not tested*
- PVE 6.3 **[OK] - Tested**
- PVE 6.4 **[OK] - Tested**
- PVE 7.2 **[OK] - Tested**
- PVE 7.4 **[OK] - Tested**
- PVE 8.2 **[OK] - Tested**
- 
### Features
1. Auto cloud images download
- Debian 9 - Stretch
- Debian 10 - Buster
- Debian 11 - bullseye
- Debian 12 - bookworm
- Ubuntu Server 18.04 LTS - Bionic
- Ubuntu Server 20.04 LTS - Focal
- Ubuntu Server 22.04 LTS - jammy
- Ubuntu Server 24.04 LTS - noble
- OpenSUSE LEAP 15.2
- CENTOS 8 
- CENTOS 9 - not support cpu kvm64 or qemu64
2. Set VM Hostname
3. Set VM Description
4. Memory (Available to select 2GB,4GB,8GB and 16GB)
5. CPU Cores
6. CPU Sockets
7. Storage destination (Local, NFS, LVM/LVM-Thin, etc)
8. Define user, by default root user is defined. If you change to another, this user can be used with sudo powers without password;
9. Insert SSH authorized keys to user defined on step 8 **Very important**;
10. Select bridge network;
11. Select Static/IP or DHCP usage;
12. Define uniq VMID;
13. Can start or not, VM after deployment.

### Usage
1. Login on your Proxmox VE server over SSH or Console Shell
2. to customize the image, the guestfs-tools package is required "apt install guestfs-tools"
4. Download script
```
wget https://raw.githubusercontent.com/DemonidZe/proxmox-cloud-init-tools/main/deploy.sh
```
5. Create authorized keys files
```
mkdir pub_keys
```
```
touch pub_keys/id_rsa.pub
```
**copy your public ssh keys to pub/keys/id_rsa.pub file**

6. Adjust permission, then run deploy.sh
```
chmod +x deploy.sh
```
```
./deploy.sh
```
7. Follow instructions on screen.

### Important
Before deploy VM using things script, upload your public ssh key to ./pub_keys/id_rsa.pub file.
if you do not upload keys do pub_keys/id_rsa.pub, you will not access VM.

### Contributors
Ananias Filho - @ananiasfilho

Frederico Siena 
