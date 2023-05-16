#!/bin/bash

############################################################################
#title           :proxmox-cloud-init-tools
#description     :This script will deploy Cloud-init images on Proxmox VE.
#author          :Ananias Filho aka kram3r
#date            :2022-06-27
#version         :1.0
#usage           :bash deploy.sh
############################################################################

clear
### SSH KEY PATH check
if [ ! -f pub_keys/id_rsa.pub ]; then
    echo "Public ssh keys file not fount!"
    echo "Create ./pub_keys/id_rsa.pub file, then paste your public ssh key file (id_rsa.pub)"
    echo "Script finished"
    exit
fi
# IMAGE PATH
IMG_PATH="imgs"
### Check if imgs path exist
if [ ! -d $IMG_PATH ] ; then
    mkdir -p $IMG_PATH
fi

#URLS - Available compatible cloud-init images to download - Debina 9/10 and Ubuntu 18.04/20.04
DEBIAN_10_URL="https://cloud.debian.org/images/cloud/buster/latest/debian-10-generic-amd64.raw"
DEBIAN_9_URL="https://cloud.debian.org/images/cloud/OpenStack/current-9/debian-9-openstack-amd64.raw"
DEBIAN_11_URL="https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.raw"
UBUNTU_1804_URL="https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img"
UBUNTU_2004_URL="https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
UBUNTU_2204_URL="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
OPENSUSE_154_URL="https://download.opensuse.org/repositories/Cloud:/Images:/Leap_15.4/images/openSUSE-Leap-15.4.x86_64-NoCloud.qcow2"
CENTOS_8_stream_URL="https://cloud.centos.org/centos/8-stream/x86_64/images/CentOS-Stream-GenericCloud-8-20220125.1.x86_64.qcow2"
CENTOS_9_stream_URL="https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-20220621.1.x86_64.qcow2"
####
echo "Available images are: "
echo -n "
1 - Debian 9 - Stretch
2 - Debian 10 - Buster
3 - Debian 11 - bullseye
4 - Ubuntu 18.04 LTS - Bionic
5 - Ubuntu 20.04 LTS - Focal
6 - Ubuntu 22.04 LTS - jammy
7 - OpenSUSE LEAP 15.4
8 - CentOS 8 stream
9 - CentOS 9 stream - not support cpu kvm64 or qemu64
"
echo -n "Choose a Image template to install: "
read OPT_IMAGE_TEMPLATE

case $OPT_IMAGE_TEMPLATE in
    1)
        TEMPLATE_VM_CI_IMAGE="$IMG_PATH/${DEBIAN_9_URL##*/}"
        if [ ! -f $TEMPLATE_VM_CI_IMAGE ]; then
            wget -c $DEBIAN_9_URL -O $TEMPLATE_VM_CI_IMAGE
        fi
        ;;
    2)
        TEMPLATE_VM_CI_IMAGE="$IMG_PATH/${DEBIAN_10_URL##*/}"
        if [ ! -f $TEMPLATE_VM_CI_IMAGE ]; then
            wget -c $DEBIAN_10_URL -O $TEMPLATE_VM_CI_IMAGE
        fi
        ;;
    3)
        TEMPLATE_VM_CI_IMAGE="$IMG_PATH/${DEBIAN_11_URL##*/}"
        if [ ! -f $TEMPLATE_VM_CI_IMAGE ]; then
            wget -c $DEBIAN_11_URL -O $TEMPLATE_VM_CI_IMAGE
        fi
        ;;
    4)
        TEMPLATE_VM_CI_IMAGE="$IMG_PATH/${UBUNTU_1804_URL##*/}"
        if [ ! -f $TEMPLATE_VM_CI_IMAGE ]; then
            wget -c $UBUNTU_1804_URL -O $TEMPLATE_VM_CI_IMAGE
        fi
        ;;
    5)
        TEMPLATE_VM_CI_IMAGE="$IMG_PATH/${UBUNTU_2004_URL##*/}"
        if [ ! -f $TEMPLATE_VM_CI_IMAGE ]; then
            wget -c $UBUNTU_2004_URL -O $TEMPLATE_VM_CI_IMAGE
        fi
        ;;
    6)
        TEMPLATE_VM_CI_IMAGE="$IMG_PATH/${UBUNTU_2204_URL##*/}"
        if [ ! -f $TEMPLATE_VM_CI_IMAGE ]; then
            wget -c $UBUNTU_2204_URL -O $TEMPLATE_VM_CI_IMAGE
        fi
        ;;
        
    7)
        TEMPLATE_VM_CI_IMAGE="$IMG_PATH/${OPENSUSE_154_URL##*/}"
        if [ ! -f $TEMPLATE_VM_CI_IMAGE ]; then
            wget -c $OPENSUSE_154_URL -O $TEMPLATE_VM_CI_IMAGE
        fi
        ;;
    8)
        TEMPLATE_VM_CI_IMAGE="$IMG_PATH/${CENTOS_8_stream_URL##*/}"
        if [ ! -f $TEMPLATE_VM_CI_IMAGE ]; then
            wget -c $CENTOS_8_stream_URL -O $TEMPLATE_VM_CI_IMAGE
        fi
        ;;
    9)
        TEMPLATE_VM_CI_IMAGE="$IMG_PATH/${CENTOS_9_stream_URL##*/}"
        if [ ! -f $TEMPLATE_VM_CI_IMAGE ]; then
            wget -c $CENTOS_9_stream_URL -O $TEMPLATE_VM_CI_IMAGE
        fi
        ;;

    *)
        clear
        echo "[Fail] - Unknown option - Run script again then choose a valid option."
        exit
        ;;
esac
clear
echo "########## VM DETAILS ##########"

echo -n "Type VM Name: "
read TEMPLATE_VM_NAME
echo
echo -n "Type VM Description: "
read TEMPLATE_VM_DESCRIPTION
echo
echo -n "Memory Options:
1 - 1GB
2 - 2GB
3 - 4GB
4 - 8GB
5 - 16GB
Select VM Memory option (1-5): "
read TEMPLATE_VM_MEMORY_GB

case $TEMPLATE_VM_MEMORY_GB in
    1)
    TEMPLATE_VM_MEMORY=1024
    ;;
    2)
        TEMPLATE_VM_MEMORY=2048
    ;;
    3)
        TEMPLATE_VM_MEMORY=4096
    ;;
    4)
        TEMPLATE_VM_MEMORY=8192
    ;;
    5)
        TEMPLATE_VM_MEMORY=16384
    ;;
        *)
                clear
                echo "[Fail] - Unknown option - Run script again then choose a valid option."
                exit
                ;;
esac
### VM Cores
echo -n "Type # of VM CPU Cores: (Example: 2)"
read TEMPLATE_VM_CORES
### VM Sockets
echo -n "Type # of VM CPU Sockets: (Example: 1)"
read TEMPLATE_VM_SOCKETS

### VM Storage
clear
echo "########## STORAGE ##########"
echo ""
echo Storage Availability|awk '{ printf "%-20s %-40s\n", $1, $2 }'
pvesm status|grep active|awk '{ printf "%-20s %-40s\n", $1, $7 }'
echo -n "Type name of Storage to install VM: "
read TEMPLATE_VM_STORAGE

### VM Default user
clear
echo "######### USER INFORMATION ##########"
echo "This tool create user root as default!"
echo "If you would like to use non-root account, please define username and use sudo when login."
echo "If you will use root, just type root or keep it empty."
echo -n "type new username: "
read TEMPLATE_DEFAULT_USER
# Check username - then define as root if empty
if [ -z $TEMPLATE_DEFAULT_USERNAME ] ; then
    TEMPLATE_DEFAULT_USERNAME="root"
fi
#### Network
clear
echo "########## NETWORK ##########"
### Bridge
echo "Choose a Bridge interface to attach VM, options are:"
    ### Get all bridges and their networks
    echo "BRIDGE NETWORK"|awk '{ printf "%-20s %-40s\n", $1, $2 }'
    for BRIDGES in `ip link |awk '{print $2}'|grep vmbr|cut -d":" -f1` ; do
            BRIDGE_NETWORK=`ip a show $BRIDGES|grep "inet "|awk '{print $2}'`
            echo "$BRIDGES $BRIDGE_NETWORK"|awk '{ printf "%-20s %-40s\n", $1, $2 }'
    done

echo -n "Type brigde name: (Example vmbr0) "
read TEMPLATE_VM_BRIDGE

echo "Use DHCP?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) DHCP_USE="Y"; break;;
        No ) echo "";;
    esac
done
if [ $DHCP_USE != "Y" ] ;then
    ### VM IP
    echo "Type VM IP Address (Example: 192.168.0.101): "
    read TEMPLATE_VM_IP_ADDR
    ### VM IP
    echo "Type VM IP BIT MASK. Example: 24, 22, 16, 8 etc." 
    echo "Your network bit mask: "
    read TEMPLATE_VM_IP_NETMASK
    TEMPLATE_VM_IP="$TEMPLATE_VM_IP_ADDR/$TEMPLATE_VM_IP_NETMASK"
    ### VM GW
    echo "Type Network Gateway IP Address. (Example: 192.168.0.1): "
    read TEMPLATE_VM_GW
fi
### VM TEMPLATE ID
echo "Choose a UNIQ ID for VM, please, do not use any of bellow IDs"
pvesh get /cluster/resources --type vm|grep qemu|awk '{ print $2}'|cut -d"/" -f2
echo -n "Type a uniq ID for VM: "
read TEMPLATE_VM_ID

clear
echo ""
echo "######### VM DETAILS ##########"
echo ""
echo Name: $TEMPLATE_VM_NAME 
echo Description $TEMPLATE_VM_DESCRIPTION 
echo Memory:  $TEMPLATE_VM_MEMORY 
echo Cores: $TEMPLATE_VM_CORES
echo Sockets: $TEMPLATE_VM_SOCKETS
echo Template Image: $TEMPLATE_VM_CI_IMAGE
echo Storage: $TEMPLATE_VM_STORAGE
echo User: $TEMPLATE_DEFAULT_USER
echo Attached Bridge: $TEMPLATE_VM_BRIDGE
echo IP Address/Network: $TEMPLATE_VM_IP
echo Gateway $TEMPLATE_VM_GW
echo VM ID: $TEMPLATE_VM_ID


echo "Review VM informations and continue"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "Starting deploy"; break;;
        No ) exit;;
    esac
done

#### Start deploy
echo ""
echo "##########  Start  VM  Deploy  ##########"
echo
#### Check if vm id exist
qm status $TEMPLATE_VM_ID > /dev/null 2>&1
if [ $? -eq 0 ] ; then
    echo "[FAIL] - unable to create VM $TEMPLATE_VM_ID - VM $TEMPLATE_VM_ID already exists - Try another id"
    exit
fi
#### Function to check errors
check_errors() {
    if [ $? -ne 0 ] ; then
        echo "[FAIL] - $ACTION"
        exit
    else
        echo "[OK] - $ACTION"
    fi
}

### DO NOT TOUCH
ACTION="Create VM Template $TEMPLATE_VM_ID:$TEMPLATE_VM_NAME"
qm create $TEMPLATE_VM_ID \
    --name $TEMPLATE_VM_NAME \
    --memory $TEMPLATE_VM_MEMORY \
    --net0 virtio,bridge=$TEMPLATE_VM_BRIDGE \
    --cores $TEMPLATE_VM_CORES \
    --sockets $TEMPLATE_VM_SOCKETS \
    --kvm 1 \
    --numa 1 > /dev/null 2>&1
check_errors

ACTION="Import disk"
qm importdisk $TEMPLATE_VM_ID $TEMPLATE_VM_CI_IMAGE $TEMPLATE_VM_STORAGE > /dev/null 2>&1
check_errors

ACTION="Set disk controller and image"
qm set $TEMPLATE_VM_ID --scsihw virtio-scsi-pci --scsi0 $TEMPLATE_VM_STORAGE:$TEMPLATE_VM_ID/vm-$TEMPLATE_VM_ID-disk-0.raw,discard=on > /dev/null 2>&1
check_errors

ACTION="Set serial socket"
qm set $TEMPLATE_VM_ID --serial0 socket > /dev/null 2>&1
check_errors

ACTION="Set boot disk"
qm set $TEMPLATE_VM_ID --boot c --bootdisk scsi0 > /dev/null 2>&1
check_errors

ACTION="Set Qemu Guest Agent Enabled"
qm set $TEMPLATE_VM_ID --agent enabled=1,fstrim_cloned_disks=1 > /dev/null 2>&1
check_errors

ACTION="Set hotplug options"
qm set $TEMPLATE_VM_ID --hotplug disk,network,usb > /dev/null 2>&1
check_errors

#ACTION="Set vga display"
#qm set $TEMPLATE_VM_ID --vga qxl > /dev/null 2>&1
#check_errors

ACTION="Set machine type"
qm set $TEMPLATE_VM_ID --machine q35 --ostype l26 > /dev/null 2>&1
check_errors

ACTION="Set name to $TEMPLATE_VM_NAME"
qm set $TEMPLATE_VM_ID --name $TEMPLATE_VM_NAME > /dev/null 2>&1
check_errors

ACTION="Set default user to $TEMPLATE_DEFAULT_USER"
qm set $TEMPLATE_VM_ID --ciuser $TEMPLATE_DEFAULT_USER > /dev/null 2>&1
check_errors

ACTION="Set image size to 10GB if image not in GB"
hdd_size=`qm config $TEMPLATE_VM_ID |grep scsi0: | awk -F"=" '{print $3}' | grep M |sed s/[^0-9]//g`
if [[ -n $hdd_size ]]
then
let "h_size = 10240 - $hdd_size"
qm resize $TEMPLATE_VM_ID scsi0 +"$h_size"M > /dev/null 2>&1
fi
#qm resize $TEMPLATE_VM_ID scsi0 +17748M > /dev/null 2>&1
check_errors

#Cloud INIT
ACTION="Add cloud-init cdrom"
qm set $TEMPLATE_VM_ID --ide2 $TEMPLATE_VM_STORAGE:cloudinit > /dev/null 2>&1
check_errors

ACTION="Set authorized ssh keys"
qm set $TEMPLATE_VM_ID --sshkey ./pub_keys/id_rsa.pub > /dev/null 2>&1
check_errors

ACTION="Set IP Address and Gateway"
if [ $DHCP_USE == Y ] ; then
    qm set $TEMPLATE_VM_ID --ipconfig0 ip=dhcp > /dev/null 2>&1
else
    qm set $TEMPLATE_VM_ID --ipconfig0 ip=$TEMPLATE_VM_IP,gw=$TEMPLATE_VM_GW > /dev/null 2>&1
fi
check_errors

clear
echo "########## Finishing deployment"
echo ""
echo "Do you wish to start this VM now?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) qm start $TEMPLATE_VM_ID; break;;
        No ) exit;;
    esac
done

echo "Now, if VM is up and running, try access $TEMPLATE_DEFAULT_USER@$TEMPLATE_VM_IP_ADDR - or check your VM ip address on DHCP Server."
echo ""
echo "Finished"
echo ""
