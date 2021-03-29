#!/bin/bash

apt install samba samba-common -y
ufw allow 139
ufw allow 445

echo "Please insert shared folder name?"
read fn
mkdir -p /var/$fn
chmod -R 0777 /var/$fn
chown -R nobody:nobody /var/$fn

read -p "Do you want to create authentication for access samba shared folder? (y / n)" mode

ase "$mode" in
	y) do
		echo "Please insert username?"
		read $un
		useradd -m -p -s $un
		echo "Please insert password?"
		read $pass
		smbpasswd -a $un
		echo "Please insert nethbios name?"
		read nbm
		echo "Please insert workgroup name? (type WORKGROUP for default)"
		read wg
		
		mv /etc/samba/smb.conf /etc/samba/smb.conf.ori
		
		cat > /etc/samba/smb.conf << EOF
		[global]
			workgroup = $wg
			netbios name = $nbm
			security = user
			map to guest = Bad User

		[$fn]
			comment = Anonymous File Server Share
			path = /var/$fn
			browsable =yes
			writable = yes
			guest ok = no
			read only = no
		EOF

		systemctl restart smbd.service
		ufw allow samba
		testpar
	;;	
	break
	
case "$mode" in
	n) do
		echo "Please insert nethbios name?"
		read nbm
		echo "Please insert workgroup name? (type WORKGROUP for default)"
		read wg
		mv /etc/samba/smb.conf /etc/samba/smb.conf.ori
		cat > /etc/samba/smb.conf << EOF
		[global]
			workgroup = $wg
			netbios name = $nbm
			security = user
			map to guest = Bad User

		[$fn]
			comment = Anonymous File Server Share
			path = /var/$fn
			browsable =yes
			writable = yes
			guest ok = yes
			read only = no
			force user = nobody
		EOF

		systemctl restart smbd.service
		ufw allow samba
		testpar
	;;
	break
