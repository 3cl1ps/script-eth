#!/bin/sh
#-----------------------------------------------------------------
# Armbian first run configuration
# Set optional end user configuration
#	- /boot/armbian_first_run.txt
#	- Settings below will be applied on 1st run of Armbian
#-----------------------------------------------------------------

#touch /tmp/first_run_lock

# Modify hostname (ethnode-$MAC-HASH-CHUNK)
MAC_HASH=`cat /sys/class/net/eth0/address | sha256sum | awk '{print substr($0,0,9)}'`
echo ethnode-$MAC_HASH > /etc/hostname
sed -i "s/127.0.1.1.*/127.0.1.1\tethnode-$MAC_HASH/g" /etc/hosts

# Format NVMe SSD and mount it as /home

if stat  /dev/nvme0n1 > /dev/null 2>&1;
then
#        echo Formatting NVMe Drive...
#        fdisk /dev/nvme0n1 <<EOF
#d
#n
#p
#1


#w
#EOF
#mkfs.ext4 -F /dev/nvme0n1p1
echo '/dev/nvme0n1p1 /home ext4 defaults 0 2' >> /etc/fstab && mount /home

else
        echo no SDD detected
fi

# Create Ethereum account
echo "Creating ethereum  user for Geth and Parity"
if ! id -u ethereum >/dev/null 2>&1; then
        adduser --disabled-password --gecos "" ethereum
fi

echo "ethereum:ethereum" | chpasswd
for GRP in sudo netdev audio video dialout plugdev bluetooth; do
	adduser ethereum $GRP
done

# Force password change on first login
chage -d 0 ethereum


# Create some swap memory in the nvme device for avoiding memory issues
if stat  /dev/nvme0n1 > /dev/null 2>&1;
then
	mkdir -p /home/ethereum/swap
	dd if=/dev/zero of=/home/ethereum/swap/swapfile bs=16k count=256k
	chmod 600 /home/ethereum/swap/swapfile
	mkswap /home/ethereum/swap/swapfile
	swapon /home/ethereum/swap/swapfile
	echo "/home/ethereum/swap/swapfile none swap sw 0 0" >> /etc/fstab
else
	echo no swap created
fi

# Disable new account creation as we already have ethereum user
rm -rf /root/.not_logged_in_yet

# Page allocation error workout
echo "vm.min_free_kbytes=262144" >> /etc/sysctl.conf

# Create an alias for updating ethereum packages
cat <<EOF >> /home/ethereum/.zshrc
alias update-ethereum='
sudo apt-get update
sudo apt-get install geth prysm prysm-beacon prysm-validator'
EOF

#-----------------------------------------------------------------
# General:
# 1 = delete this file, after first run setup is completed.
#	SECURITY WARN: Even if this file is deleted, it may still be accessible by recovery methods.
FR_general_delete_this_file_after_completion=1
