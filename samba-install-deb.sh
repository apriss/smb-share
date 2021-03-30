#!/bin/bash

apt update
apt install samba samba-common -y

echo "Please insert shared folder name?"
read fn
mkdir -p /var/$fn
chmod -R 0777 /var/$fn
chown -R nobody:nogroup /var/$fn

mv /etc/samba/smb.conf /etc/samba/smb.conf.ori

echo "Please insert nethbios name?"
read nbn
echo "Please insert workgroup name? (type WORKGROUP for default)"
read wg

read -p "Do you want to create authentication for access samba shared folder? (y / n)" mode
case "$mode" in
	y) do
		echo "Please insert username?"
		read $un
		useradd -m -p -s $un
		echo "Please insert password?"
		read $pass
		smbpasswd -a $un
				
		cat > /etc/samba/smb.conf << EOF
		[global]
			workgroup = $wg
			netbios name = $nbn
			security = user

		[$fn]
			path = /var/$fn
			browsable =yes
			writable = yes
			guest ok = no
			read only = no
		EOF
	;;	
	
case "$mode" in
	n) do
		cat > /etc/samba/smb.conf << EOF
		[global]
			workgroup = $wg
			netbios name = $nbn
			security = user
			map to guest = Bad User

		[$fn]
			path = /var/$fn
			browsable =yes
			writable = yes
			guest ok = yes
			read only = no
			force user = nobody
		EOF
	;;
	
systemctl restart smbd.service
ufw allow samba
testpar

