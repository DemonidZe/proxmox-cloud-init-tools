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
pvever=`pveversion | awk -F'[/]' '{print $2}' | awk -F'[-]' '{print $1}'`

DEBIAN_9_URL="https://cloud.debian.org/images/cloud/OpenStack/current-9/debian-9-openstack-amd64.raw"
DEBIAN_10_URL="https://cloud.debian.org/images/cloud/buster/latest/debian-10-generic-amd64.raw"
DEBIAN_11_URL="https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.raw"
DEBIAN_12_URL="https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.raw"
UBUNTU_1804_URL="https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img"
UBUNTU_2004_URL="https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
UBUNTU_2204_URL="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
UBUNTU_2404_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
OPENSUSE_154_URL="https://download.opensuse.org/repositories/Cloud:/Images:/Leap_15.4/images/openSUSE-Leap-15.4.x86_64-NoCloud.qcow2"
OPENSUSE_156_URL="https://download.opensuse.org/repositories/Cloud:/Images:/Leap_15.6/images/openSUSE-Leap-15.6.x86_64-NoCloud.qcow2"
CENTOS_8_stream_URL="https://cloud.centos.org/centos/8-stream/x86_64/images/CentOS-Stream-GenericCloud-8-latest.x86_64.qcow2"
CENTOS_9_stream_URL="https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2"
####
echo "Available images are: "
echo -n "
1 - Debian 9 - Stretch
2 - Debian 10 - Buster
3 - Debian 11 - bullseye
4 - Debian 12 - bookworm
5 - Ubuntu 18.04 LTS - Bionic
6 - Ubuntu 20.04 LTS - Focal
7 - Ubuntu 22.04 LTS - jammy
8 - Ubuntu 24.04 LTS - noble
9 - OpenSUSE LEAP 15.4
10 - OpenSUSE LEAP 15.6
11 - CentOS 8 stream
12 - CentOS 9 stream - not support cpu kvm64 or qemu64
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
        TEMPLATE_VM_CI_IMAGE="$IMG_PATH/${DEBIAN_12_URL##*/}"
        if [ ! -f $TEMPLATE_VM_CI_IMAGE ]; then
            wget -c $DEBIAN_12_URL -O $TEMPLATE_VM_CI_IMAGE
        fi
        ;;
    5)
        TEMPLATE_VM_CI_IMAGE="$IMG_PATH/${UBUNTU_1804_URL##*/}"
        if [ ! -f $TEMPLATE_VM_CI_IMAGE ]; then
            wget -c $UBUNTU_1804_URL -O $TEMPLATE_VM_CI_IMAGE
        fi
        ;;
    6)
        TEMPLATE_VM_CI_IMAGE="$IMG_PATH/${UBUNTU_2004_URL##*/}"
        if [ ! -f $TEMPLATE_VM_CI_IMAGE ]; then
            wget -c $UBUNTU_2004_URL -O $TEMPLATE_VM_CI_IMAGE
        fi
        ;;
    7)
        TEMPLATE_VM_CI_IMAGE="$IMG_PATH/${UBUNTU_2204_URL##*/}"
        if [ ! -f $TEMPLATE_VM_CI_IMAGE ]; then
            wget -c $UBUNTU_2204_URL -O $TEMPLATE_VM_CI_IMAGE
        fi
        ;;
    8)
        TEMPLATE_VM_CI_IMAGE="$IMG_PATH/${UBUNTU_2404_URL##*/}"
        if [ ! -f $TEMPLATE_VM_CI_IMAGE ]; then
            wget -c $UBUNTU_2404_URL -O $TEMPLATE_VM_CI_IMAGE
        fi
        ;;

    9)
        TEMPLATE_VM_CI_IMAGE="$IMG_PATH/${OPENSUSE_154_URL##*/}"
        if [ ! -f $TEMPLATE_VM_CI_IMAGE ]; then
            wget -c $OPENSUSE_154_URL -O $TEMPLATE_VM_CI_IMAGE
        fi
        ;;

    10)
        TEMPLATE_VM_CI_IMAGE="$IMG_PATH/${OPENSUSE_156_URL##*/}"
        if [ ! -f $TEMPLATE_VM_CI_IMAGE ]; then
            wget -c $OPENSUSE_156_URL -O $TEMPLATE_VM_CI_IMAGE
        fi
        ;;

    11)
        TEMPLATE_VM_CI_IMAGE="$IMG_PATH/${CENTOS_8_stream_URL##*/}"
        if [ ! -f $TEMPLATE_VM_CI_IMAGE ]; then
            wget -c $CENTOS_8_stream_URL -O $TEMPLATE_VM_CI_IMAGE
        fi
        ;;
    12)
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

echo "enable ssh password login?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) SSH_PASSWORD="Yes"; break;;
        No )  SSH_PASSWORD="No"; break;;
    esac
done

echo "install additional packages? (qemu-guest-agent installed by default)"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) PACK_INSTALL=1; break;;
        No )  PACK_INSTALL=0; break;;
    esac
done

if [ $PACK_INSTALL == 1 ] ; then
echo -n "Specify packages separated by comma: (Example: htop,mc,atop) "
read TEMPLATE_VM_PACK
fi



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

echo "Use NUMA?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) TEMPLATE_NUMA=1; break;;
        No ) TEMPLATE_NUMA=0; break;;
    esac
done
echo "Start on boot"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) TEMPLATE_START=YES; break;;
        No ) TEMPLATE_START=NO; break;;
    esac
done

### VM Storage
clear
echo "########## STORAGE ##########"
echo ""
echo Storage Availability|awk '{ printf "%-20s %-40s\n", $1, $2 }'
pvesm status|grep active|awk '{ printf "%-20s %-40s\n", $1, $7 }'
echo -n "Type name of Storage to install VM: "
read TEMPLATE_VM_STORAGE
clear
### VM Disk Size
echo ""
echo -n "How much to increase the disk from 5gb (Example: 10G) or press enter: "
read TEMPLATE_VM_DISKSIZE
### VM Default user
clear
echo "######### USER INFORMATION ##########"
echo "This tool create user root as default!"
echo "If you would like to use non-root account, please define username and use sudo when login."
echo "If you will use root, just type root or keep it empty."
echo -n "Enter new username: "
read TEMPLATE_DEFAULT_USERNAME
# Check username - then define as root if empty
if [ -z $TEMPLATE_DEFAULT_USERNAME ] ; then
    TEMPLATE_DEFAULT_USERNAME="root"
fi
clear
echo -n "Enter password for user: $TEMPLATE_DEFAULT_USERNAME "
read -s -p "Password: " TEMPLATE_PASSWD
clear
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
clear
echo -n "enter VLANID if required: "
read TEMPLATE_VLANID

echo "Use DHCP?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) DHCP_USE=YES; break;;
        No ) DHCP_USE=NO; break;;
    esac
done
if [ $DHCP_USE == "NO" ] ;then
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
echo "Choose a UNIQ ID for VM, the first free id is indicated. You can contribute yours"
freeid=$(pvesh get /cluster/nextid)
#pvesh get /cluster/resources --type vm|grep qemu|awk '{ print $2}'|cut -d"/" -f2
echo -n "First free id: $freeid "
read TEMPLATE_VM_ID

if [ -z $TEMPLATE_VM_ID ]; then
    TEMPLATE_VM_ID=$freeid
fi


clear
echo ""
echo "######### VM DETAILS ##########"
echo ""
echo Name: $TEMPLATE_VM_NAME 
echo Description: $TEMPLATE_VM_DESCRIPTION 
echo Memory:  $TEMPLATE_VM_MEMORY 
echo Cores: $TEMPLATE_VM_CORES
echo Sockets: $TEMPLATE_VM_SOCKETS
echo NUMA: $TEMPLATE_NUMA
echo Template Image: $TEMPLATE_VM_CI_IMAGE
echo Storage: $TEMPLATE_VM_STORAGE
if [ -z "$TEMPLATE_VM_DISKSIZE" ]
    then
echo "Default disk size"
else
echo "Disk size set to:" $TEMPLATE_VM_DISKSIZE
fi
echo "Enable password login for SSH:" $SSH_PASSWORD 
echo Additional packages: $TEMPLATE_VM_PACK
echo Add user: $TEMPLATE_DEFAULT_USERNAME
if [ -z "$TEMPLATE_PASSWD" ]
    then
echo "Password not set for user: $TEMPLATE_DEFAULT_USERNAME"
else
echo "Password for user: $TEMPLATE_DEFAULT_USERNAME is set"
fi
echo Attached Bridge: $TEMPLATE_VM_BRIDGE
echo VLANID: $TEMPLATE_VLANID
echo Use DHCP: $DHCP_USE
echo IP Address/Network: $TEMPLATE_VM_IP
echo Gateway: $TEMPLATE_VM_GW
echo VM ID: $TEMPLATE_VM_ID
echo Start on boot: $TEMPLATE_START


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

cp -f "$TEMPLATE_VM_CI_IMAGE" "$TEMPLATE_VM_CI_IMAGE"_tmp

    if [ $SSH_PASSWORD == Yes ] ; then
        echo "changing configuration in template $TEMPLATE_VM_CI_IMAGE"
	virt-edit -a "$TEMPLATE_VM_CI_IMAGE"_tmp /etc/ssh/sshd_config -e 's/#PasswordAuthentication no/PasswordAuthentication yes/'
	virt-edit -a "$TEMPLATE_VM_CI_IMAGE"_tmp /etc/ssh/sshd_config -e 's/PasswordAuthentication no/PasswordAuthentication yes/'
	virt-edit -a "$TEMPLATE_VM_CI_IMAGE"_tmp /etc/ssh/sshd_config -e 's/#PasswordAuthentication yes/PasswordAuthentication yes/'

    fi

    if [ -z $TEMPLATE_VM_PACK ] ; then
	echo "install qemu-guest-agent"
	virt-customize -a "$TEMPLATE_VM_CI_IMAGE"_tmp --install qemu-guest-agent
    else
        echo "install additional packages"
	virt-customize -a "$TEMPLATE_VM_CI_IMAGE"_tmp --install qemu-guest-agent,$TEMPLATE_VM_PACK
    fi



### DO NOT TOUCH
ACTION="Create VM Template $TEMPLATE_VM_ID:$TEMPLATE_VM_NAME"
qm create $TEMPLATE_VM_ID \
    --name $TEMPLATE_VM_NAME \
    --memory $TEMPLATE_VM_MEMORY \
    --net0 virtio,bridge=$TEMPLATE_VM_BRIDGE \
    --cores $TEMPLATE_VM_CORES \
    --sockets $TEMPLATE_VM_SOCKETS \
    --numa $TEMPLATE_NUMA > /dev/null 2>&1
check_errors

ACTION="Import disk"
qm importdisk $TEMPLATE_VM_ID "$TEMPLATE_VM_CI_IMAGE"_tmp $TEMPLATE_VM_STORAGE > /dev/null 2>&1
check_errors
rm -f "$TEMPLATE_VM_CI_IMAGE"_tmp

ACTION="Set disk controller and image"
if [[ "$pvever" > "7.3" ]]
then 
qm set $TEMPLATE_VM_ID --scsihw virtio-scsi-single --scsi0 $TEMPLATE_VM_STORAGE:$TEMPLATE_VM_ID/vm-$TEMPLATE_VM_ID-disk-0.raw,discard=on > /dev/null 2>&1
#echo "ver 7.4 +"
else
qm set $TEMPLATE_VM_ID --scsihw virtio-scsi-single --scsi0 $TEMPLATE_VM_STORAGE:vm-$TEMPLATE_VM_ID-disk-0,discard=on > /dev/null 2>&1
#echo "old ver"
fi
check_errors

if [ $TEMPLATE_VLANID ]; then
ACTION="Set VALNID"
qm set $TEMPLATE_VM_ID --net0 virtio,bridge=$TEMPLATE_VM_BRIDGE,tag=$TEMPLATE_VLANID  > /dev/null 2>&1
check_errors
fi

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

ACTION="Set tablet mode off"
qm set $TEMPLATE_VM_ID --tablet 0 > /dev/null 2>&1
check_errors

#ACTION="Set vga display"
#qm set $TEMPLATE_VM_ID --vga qxl > /dev/null 2>&1
#check_errors
if [[ "$pvever" > "8.0" ]]
 then
ACTION="Set machine type"
qm set $TEMPLATE_VM_ID --machine q35 --ostype l26 --cpu x86-64-v2-AES > /dev/null 2>&1
check_errors
else
ACTION="Set machine type"
qm set $TEMPLATE_VM_ID --machine q35 --ostype l26 > /dev/null 2>&1
check_errors
fi

ACTION="Set name to $TEMPLATE_VM_NAME"
qm set $TEMPLATE_VM_ID --name $TEMPLATE_VM_NAME > /dev/null 2>&1
check_errors

ACTION="Add users: $TEMPLATE_DEFAULT_USERNAME"
qm set $TEMPLATE_VM_ID --ciuser $TEMPLATE_DEFAULT_USERNAME > /dev/null 2>&1
check_errors

if [ -z $TEMPLATE_PASSWD ]; then
echo "Password for user not set"
else
ACTION="set password for user"
qm set $TEMPLATE_VM_ID --cipassword "$TEMPLATE_PASSWD" > /dev/null 2>&1
check_errors
fi

hdd_size=`qm config $TEMPLATE_VM_ID |grep scsi0: | awk -F"=" '{print $3}' | grep M |sed s/[^0-9]//g`
if [[ -n $hdd_size ]]
then
ACTION="Set image size to 5GB if the size is not in gigabytes"
let "h_size = 5120 - $hdd_size"
qm resize $TEMPLATE_VM_ID scsi0 +"$h_size"M > /dev/null 2>&1
#qm resize $TEMPLATE_VM_ID scsi0 +17748M > /dev/null 2>&1
check_errors
fi

if [ -z $TEMPLATE_VM_DISKSIZE ]; then
hdd_size1=`qm config $TEMPLATE_VM_ID |grep scsi0: | awk -F"=" '{print $3}'`
echo "hdd size now is: $hdd_size1" 
else
ACTION="Set image size to $TEMPLATE_VM_DISKSIZE "
qm resize $TEMPLATE_VM_ID scsi0 "$TEMPLATE_VM_DISKSIZE" > /dev/null 2>&1
check_errors
hdd_size1=`qm config $TEMPLATE_VM_ID |grep scsi0: | awk -F"=" '{print $3}'`
echo "hdd size now is: $hdd_size1" 
fi
#Cloud INIT
ACTION="Add cloud-init cdrom"
qm set $TEMPLATE_VM_ID --ide2 $TEMPLATE_VM_STORAGE:cloudinit > /dev/null 2>&1
check_errors

ACTION="Set authorized ssh keys"
qm set $TEMPLATE_VM_ID --sshkey ./pub_keys/id_rsa.pub > /dev/null 2>&1
check_errors

if [ $DHCP_USE == "YES" ]
then
ACTION="Set DHCP use"
qm set $TEMPLATE_VM_ID --ipconfig0 ip=dhcp > /dev/null 2>&1
check_errors
else
ACTION="Set IP Address and Gateway"
qm set $TEMPLATE_VM_ID --ipconfig0 ip=$TEMPLATE_VM_IP,gw=$TEMPLATE_VM_GW > /dev/null 2>&1
check_errors
fi

if [ $TEMPLATE_START == "YES" ]; then
ACTION="Set start on boot"
qm set $TEMPLATE_VM_ID --onboot 1  > /dev/null 2>&1
check_errors
fi
echo "########## Finishing deployment"
echo ""
echo "Do you wish to start this VM now?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) qm start $TEMPLATE_VM_ID; break;;
        No ) break;;
    esac
done

echo "Now, if VM is up and running, try access $TEMPLATE_DEFAULT_USER@$TEMPLATE_VM_IP_ADDR - or check your VM ip address on DHCP Server."
echo ""
echo "Finished"
echo ""
