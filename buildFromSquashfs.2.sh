#!/bin/bash

echo
echo "Bau aus vorhandenem squashfs ubuntu 20.04.2 64 Bit"
echo "====================================="
echo
echo "1. Das vorliegende Skript bitte in (L)Ubuntu 20.04.2 64 Bit per sudo auf der Kommandozeile/im Terminal ausfuehren."
read -r -p "Neubau des live.iso? [j/N] " questionResponse
echo 
if [[ $questionResponse != [jJ] ]]
then
	exit
fi

if ! head -1 /etc/issue | grep -q 'Ubuntu 20.04.2' || ! [ $(getconf LONG_BIT) == '64' ]
then
	echo "Sie benutzen die falsche (L)Ubuntu-Version. Bitte (L)Ubuntu 20.04.2 64 Bit verwenden."
	exit
fi

set -o xtrace

date > ./date.start
rm live.iso

#### Return-Values der Bash-Kommandos auswerten #### BEGIN #####

function CHECK {
	#if [ ${PIPESTATUS[0]} -ne 0 ]
	if [ $? -eq 0 ]
	then
		echo $(tput bold)$(tput setaf 2)[PASS]$(tput sgr0)
	else
		echo $(tput bold)$(tput setaf 1)[FAIL]$(tput sgr0)
	fi
}
export PS4='$(CHECK)\n\n$(tput bold)$(tput setaf 7)$(tput setab 4)+ (${BASH_SOURCE}:${LINENO}):$(tput sgr0) '

#### Return-Values der Bash-Kommandos auswerten #### END #######


#### System bauen #### BEGIN ####

# Ressourcen des Build-Systems in Live-System hineinmappen
mount --bind /dev squashfs/dev
mount -t devpts devpts squashfs/dev/pts
mount -t proc proc squashfs/proc
mount -t sysfs sysfs squashfs/sys

# DNS + Paketquellen des Build-Systems nutzen, vorher Ressourcen des Live-Systems sichern
chroot squashfs/ cp -dp /etc/resolv.conf /etc/resolv.conf.original
chroot squashfs/ cp -dp /etc/apt/sources.list /etc/apt/sources.list.original
cp /etc/resolv.conf squashfs/etc/
cp /etc/apt/sources.list squashfs/etc/apt/

# alle Updates einspielen
chroot squashfs/ apt-get update
chroot squashfs/ apt-get -y upgrade

# Zusaetzliche Pakete einspielen
chroot squashfs/ apt-get -y install tzdata language-pack-de firefox-locale-de squashfs-tools cups wswiss wngerman wogerman aspell-de hunspell-de-de

# Zeitzone setzen
echo "Europe/Berlin" | tee squashfs/etc/timezone
rm squashfs/etc/localtime
chroot squashfs/ ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime
chroot squashfs/ dpkg-reconfigure --frontend noninteractive tzdata

# Microcodes + Tools nachinstallieren, die durch das Entfernen der linux*-Pakete verloren gegangen sind
chroot squashfs/ apt-get -y install amd64-microcode intel-microcode iucode-tool thermald

# APT + Software-Center aufrauemen
chroot squashfs/ apt-get -y check
chroot squashfs/ apt-get -y autoremove --purge
chroot squashfs/ apt-get -y clean


# Echtzeituhr: Lokalzeit anstatt UTC verwenden für Dual-Boot mit Windows
echo "0.0 0 0" > squashfs/etc/adjtime
echo "0" >> squashfs/etc/adjtime
echo "LOCAL" >> squashfs/etc/adjtime

#### System bauen #### END ######

# jetzt:
# hier ist die Änderung:
# Firefox-Profil ins Zielsystem kopieren
rm -rf squashfs/etc/skel
cp -r source/skel squashfs/etc/


umount squashfs/dev/pts squashfs/dev squashfs/proc squashfs/sys

#mv squashfs/etc/resolv.conf.orig squashfs/etc/resolv.conf
chroot squashfs/ mv /etc/resolv.conf.original /etc/resolv.conf
chroot squashfs/ mv /etc/apt/sources.list.original /etc/apt/sources.list

mksquashfs squashfs iso/casper/filesystem.squashfs -noappend -comp lz4 -Xhc
genisoimage -cache-inodes -r -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o live.iso -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot iso

isohybrid -u live.iso

#### Iso erzeugen #### END ######
date > ./date.end
date
echo
