#!/bin/bash
#
#	Dieses Script ist eine Variation des 
#       https://github.com/ctbankix-continuation-team/ctbankix-continuation/blob/master/ctbankix-continuation_Lubuntu_64_20.04.2.sh
#       Copyright: siehe dort :-)
#       Der Veränderungsvorschlag kann im Forum nachgelesen werden:
#       https://www.heise.de/forum/c-t/Kommentare-zu-c-t-Artikeln/Sicheres-Online-Banking-mit-Bankix/Re-Lubuntu-20-04-2-LTS/posting-38966791/show/
##
##       Wer Lust hat, über dieses Script speziell oder über Änderungen am ctbankix-Script generell zu diskutieren, kann mich erreichen.
##       Bei der von Heinlein betriebenen Mailbox habe ich einen Account. In der letzten Zeile dieses Kommentars gebe ich den User-Namen an.
##       Er ist identisch mit dem Pseudonym auf dem Forum. (smtp: Klein) 
##       Sorry für diese Kryptik :-( aber wenn du damit Probleme hast, dann soll es wohl nicht sein ;-)
##
#       In o.g. Script ctbankix-continuation_Lubuntu_64_20.04.2.sh heißt es:
#
#       < wget -O /usr/lib/firefox-addons/extensions/{20fc2e06-e3e4-4b2b-812b-ab431220cada}.xpi https://addons.mozilla.org/firefox/downloads/file/839942/startpagecom_private_search_engine-1.1.2-an+fx-linux.xpi
#
#       Nach meiner Erfahrung kommt dadurch startpage.com als Suchmaschine aber nicht in Reichweite.
#       Ich habe auch keinen Weg gefunden, die Suchmaschine über ein Script installieren zu können.
#       Am nächsten komme ich einer Lösung, wenn ich das startpage-Addon in lokale "extensions"
#       lade wie folgt und dann anschließend noch etwas nacharbeite, siehe weiter unten.
#       Hier die "diffs":
#
#       > mkdir -p /etc/skel/.mozilla/firefox/ctbankix.default
#       > mkdir -p /etc/skel/.mozilla/firefox/besondersGehaertetesProfil.default
#
#       wird zu
#
#       < mkdir -p /etc/skel/.mozilla/firefox/ctbankix.default/extensions
#       < mkdir -p /etc/skel/.mozilla/firefox/besondersGehaertetesProfil.default/extensions
#
#       Das kommentiere ich aus:
#       < # wget -O /usr/lib/firefox-addons/extensions/{20fc2e06-e3e4-4b2b-812b-ab431220cada}.xpi https://addons.mozilla.org/firefox/downloads/file/839942/startpagecom_private_search_engine-1.1.2-an+fx-linux.xpi
#
#       und nun lade ich:
#
#       < wget -O /etc/skel/.mozilla/firefox/ctbankix.default/extensions/{20fc2e06-e3e4-4b2b-812b-ab431220cada}.xpi https://addons.mozilla.org/firefox/downloads/file/839942
#       < wget -O /etc/skel/.mozilla/firefox/besondersGehaertetesProfil.default/extensions/{20fc2e06-e3e4-4b2b-812b-ab431220cada}.xpi https://addons.mozilla.org/firefox/downloads/file/839942
#
#       Letzteres kann durch ein Kopie von "ctbankix.default" nach "besondersGehaertetesProfil" anstatt des zweiten Downloads etwas verschönt werden ...
#
#       Das Ergebnis ist, dass beim ersten Aufruf des Firefox ein gelbes Achtung-Zeichen erscheint und dann mit wenigen Mausklicks Startpage.com als Suchmaschine festgelegt werden kann.
#
#
#       Ausgangspunkt:
#         
#         der Kernel ist bereits mit o.g. Script erstellt worden
#         lubuntu-20.04.2-desktop-amd64.iso ist im Verzeichnis source
##
#       Ziel:
#         startpage.com als Suchmaschine etwas besser vorbereiten als es in o.g. Script gemacht wird;
#
#
#       DebianUser
#
#
echo
echo "Update für Lubuntu 20.04.2 64 Bit aus ctbankix-continuation"
echo "====================================="
echo
echo "1. Das vorliegende Skript bitte in (L)Ubuntu 20.04.2 64 Bit per sudo auf der Kommandozeile/im Terminal ausfuehren."
echo "2. Nach Durchlauf des Skriptes steht ein ISO-Image (live.iso) bereit, dass auf einen USB-Stick gebracht werden muss."
echo "  a) Den USB-Stick (min. 4 GB, besser 8 GB) entsprechend (eine Partition, FAT32) formatieren (bspw. mithilfe der Anwendung 'Laufwerke')."
echo "  b) Das Bootflag des Sticks setzen (bspw. mithilfe der Anwendung 'GParted')."
echo "  c) Das ISO-Image (live.iso) mithilfe der Anwendung 'UNetbootin' auf den Stick bringen (PS: Der Startmedienersteller ermoeglicht keine volle Funktionalitaet des bankix-Systems)."
echo
read -r -p "Das habe ich verstanden. [j/N] " questionResponse
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

#### Kernel bauen #### BEGIN ####
#### Kernel liegt vor
#### Kernel bauen #### END ######


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

## Altes, Störendes entfernen
rm -rf live.iso
rm -rf iso
rm -rf squashfs
rm -rf source/skel

#### System bauen #### BEGIN ####

# lubuntu-20.04.2-desktop-amd64.iso liegt im Verzeichnis source

mount -o loop source/lubuntu-20.04.2-desktop-amd64.iso /mnt/
mkdir iso
cp -r /mnt/.disk/ /mnt/boot/ /mnt/EFI/ iso/
mkdir iso/casper

# Bereits gebautes Live-System des verwendeteten ISOs entpacken
unsquashfs -d squashfs /mnt/casper/filesystem.squashfs

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

# Locales setzen
chroot squashfs/ locale-gen de_DE.UTF-8
chroot squashfs/ locale-gen de_CH.UTF-8

# System schlank machen
chroot squashfs/ apt-get -y purge libreoffice-* trojita* skanlite blue* quassel* transmission-* 2048-qt k3b* vlc* vim* noblenote xscreensaver* snapd fonts-noto-cjk git* oxygen-icon-theme calamares* language-pack* lvm2 apport btrfs* cryptsetup genisoimage xul-ext-ubufox

chroot squashfs/ apt-get -y purge linux-image-* linux-headers-* linux-modules-* 
chroot squashfs/ apt-get -y autoremove --purge

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

# Modifizierten Kernel einspielen
cp kernel/linux*headers*.deb kernel/linux-image*.deb kernel/linux-modules*.deb squashfs/
chroot squashfs/ ls | chroot squashfs/ grep .deb | chroot squashfs/ tr '\n' ' ' | chroot squashfs/ xargs dpkg -i
chroot squashfs/ apt-get -f -y install
rm squashfs/*.deb

# Microcodes + Tools nachinstallieren, die durch das Entfernen der linux*-Pakete verloren gegangen sind
chroot squashfs/ apt-get -y install amd64-microcode intel-microcode iucode-tool thermald

# APT + Software-Center aufrauemen
chroot squashfs/ apt-get -y check
chroot squashfs/ apt-get -y autoremove --purge
chroot squashfs/ apt-get -y clean

# Firefox-Profil im Ordner source/skel erzeugen
mkdir -p source/skel/.mozilla/firefox/ctbankix.default/extensions
mkdir -p source/skel/.mozilla/firefox/besondersGehaertetesProfil.default/extensions

# Plugins nachladen
wget -O squashfs/usr/lib/firefox-addons/extensions/{73a6fe31-595d-460b-a920-fcc0f8843232}.xpi https://addons.mozilla.org/firefox/downloads/latest/noscript/
wget -O squashfs/usr/lib/firefox-addons/extensions/https-everywhere@eff.org.xpi https://addons.mozilla.org/firefox/downloads/latest/https-everywhere/
rm -rf squashfs/usr/lib/firefox/distribution/searchplugins/locale/

# Besonders gehaertetes Profil nach 'pyllyukko' anlegen
wget -O source/skel/.mozilla/firefox/besondersGehaertetesProfil.default/user.js https://raw.githubusercontent.com/pyllyukko/user.js/master/user.js
sed -i -e 's/^user_pref("browser.search.countryCode",.*/user_pref("browser.search.countryCode","DE");/' source/skel/.mozilla/firefox/besondersGehaertetesProfil.default/user.js
sed -i -e 's/^user_pref("browser.search.region",.*/user_pref("browser.search.region","DE");/' source/skel/.mozilla/firefox/besondersGehaertetesProfil.default/user.js
sed -i -e 's/^user_pref("intl.accept_languages",.*/user_pref("intl.accept_languages","de-de,de");/' source/skel/.mozilla/firefox/besondersGehaertetesProfil.default/user.js

cat >> source/skel/.mozilla/firefox/besondersGehaertetesProfil.default/user.js << EOF
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.startup.homepage", "about:blank");
user_pref("browser.disableResetPrompt", true);
EOF

# Startpage zu den Suchmaschinen hinzufuegen
wget -O source/skel/.mozilla/firefox/ctbankix.default/extensions/{20fc2e06-e3e4-4b2b-812b-ab431220cada}.xpi https://addons.mozilla.org/firefox/downloads/file/839942
cp  source/skel/.mozilla/firefox/ctbankix.default/extensions/{20fc2e06-e3e4-4b2b-812b-ab431220cada}.xpi source/skel/.mozilla/firefox/besondersGehaertetesProfil.default/extensions/

# Firefox-Einstellungen
cat > squashfs/usr/lib/firefox/defaults/pref/ctbankixAutoConfig.js << EOF
pref("general.config.filename", "ctbankixFirefoxConfig.cfg");
pref("general.config.obscure_value", 0);
EOF

cat > squashfs/usr/lib/firefox/ctbankixFirefoxConfig.cfg << EOF
// Deaktiviert den Updater
lockPref("app.update.enabled", false);
// Stellt sicher dass er tatsächlich abgestellt ist
lockPref("app.update.auto", false);
lockPref("app.update.mode", 0);
lockPref("app.update.service.enabled", false);

// Deaktiviert die Kompatbilitätsprüfung der Add-ons
// clearPref("extensions.lastAppVersion"); 

// Deaktiviert 'Kenne deine Rechte' beim ersten Start
pref("browser.rights.3.shown", true);

// Versteckt 'Was ist neu?' beim ersten Start nach jedem Update
pref("browser.startup.homepage_override.mstone","ignore");

// Stellt eine Standard-Homepage ein - Nutzer können sie ändern
// defaultPref("browser.startup.homepage", "http://home.example.com");

// Deaktiviert den internen PDF-Viewer
// pref("pdfjs.disabled", true);

// Deaktiviert den Flash zu JavaScript Converter
pref("shumway.disabled", true);

// Verhindert die Frage nach der Installation des Flash Plugins
pref("plugins.notifyMissingFlash", false);

//Deaktiviert das 'plugin checking'
//lockPref("plugins.hide_infobar_for_outdated_plugin", true);
//clearPref("plugins.update.url");

// Deaktiviert den 'health reporter'
lockPref("datareporting.healthreport.service.enabled", false);

// Disable all data upload (Telemetry and FHR)
lockPref("datareporting.policy.dataSubmissionEnabled", false);

// Deaktiviert den 'crash reporter'
lockPref("toolkit.crashreporter.enabled", false);
Components.classes["@mozilla.org/toolkit/crash-reporter;1"].getService(Components.interfaces.nsICrashReporter).submitReports = false;
EOF

cat > source/skel/.mozilla/firefox/profiles.ini << EOF
[General]
StartWithLastProfile=0

[Profile0]
Name=Bisheriges ctbankix-Profil
IsRelative=1
Path=ctbankix.default

[Profile1]
Name=Besonders Gehaertetes Profil
IsRelative=1
Path=besondersGehaertetesProfil.default
EOF

cat > source/skel/.mozilla/firefox/ctbankix.default/prefs.js << EOF
# Mozilla User Preferences

/* Do not edit this file.
 *
 * If you make changes to this file while the application is running,
 * the changes will be overwritten when the application exits.
 *
 * To make a manual change to preferences, you can visit the URL about:config
 */

user_pref("browser.cache.disk.capacity", 0);
user_pref("browser.download.useDownloadDir", false);
user_pref("browser.privatebrowsing.autostart", true);
user_pref("browser.search.update", false);
user_pref("browser.startup.homepage", "https://www.heise.de/ct/projekte/ctbankix");
user_pref("browser.startup.page", 0);
user_pref("capability.policy.maonoscript.sites", "[System+Principal] about: about:addons about:blank about:blocked about:certerror about:config about:crashes about:feeds about:home about:memory about:neterror about:plugins about:pocket-saved about:pocket-signup about:preferences about:privatebrowsing about:sessionrestore about:srcdoc about:support blob: chrome: mediasource: moz-extension: moz-safe-about: resource:");
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("extensions.lastAppVersion", "50.0.2");
user_pref("network.cookie.prefsMigrated", true);
user_pref("network.predictor.cleaned-up", true);
user_pref("privacy.donottrackheader.enabled", true);
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.disableResetPrompt", true);
EOF

# Firefox-Profil ins Zielsystem kopieren
cp -r source/skel squashfs/etc/

# Menue bauen
mkdir iso/isolinux
cp /mnt/isolinux/boot.cat /mnt/isolinux/isolinux.bin /mnt/isolinux/*.c32 iso/isolinux/

# Boot (ohne UEFI)
# Schweiz:
# - "locale=de_DE" ersetzen durch "locale=de_CH"
# - "layoutcode=de" ersetzen durch "layoutcode=ch"
cat > iso/isolinux/isolinux.cfg << EOF
default vesamenu.c32
menu title c't Bankix Lubuntu 20.04.2

label ctbankix
  menu label c't Bankix Lubuntu 20.04.2
  kernel /casper/vmlinuz
  append BOOT_IMAGE=/casper/vmlinuz boot=casper initrd=/casper/initrd.lz showmounts quiet splash noprompt -- debian-installer/locale=de_DE console-setup/layoutcode=de
  
label local
  menu label Betriebssystem von Festplatte starten
  localboot 0x80
EOF

# Boot (mit UEFI)
cat > iso/boot/grub/grub.cfg << EOF

if loadfont /boot/grub/font.pf2 ; then
	set gfxmode=auto
	insmod efi_gop
	insmod efi_uga
	insmod gfxterm
	terminal_output gfxterm
fi

set menu_color_normal=white/black
set menu_color_highlight=black/light-gray

menuentry "c't Bankix Lubuntu 20.04.2" {
	set gfxpayload=keep
	linux	/casper/vmlinuz boot=casper showmounts quiet splash noprompt -- debian-installer/locale=de_DE console-setup/layoutcode=de
	initrd	/casper/initrd.lz
}
EOF


# apt-Pinning um das Einspielen ungepatchter Kernel zu verhindern
cat > squashfs/etc/apt/preferences << EOF
Package: linux-image*
Pin: origin *.ubuntu.com
Pin-Priority: -1

Package: linux-headers*
Pin: origin *.ubuntu.com
Pin-Priority: -1

Package: linux-modules*
Pin: origin *.ubuntu.com
Pin-Priority: -1

Package: linux-lts*
Pin: origin *.ubuntu.com
Pin-Priority: -1

Package: linux-generic*
Pin: origin *.ubuntu.com
Pin-Priority: -1
EOF

cat > squashfs/excludes << EOF
casper/*
cdrom/*
cow/*
etc/mtab
home/lubuntu/.cache/*
media/*
mnt/*
proc/*
rofs/*
root/.cache/*
sys/*
tmp/*
var/log/*
EOF


# Skript zur Erzeugung des Snapshots bereitstellen

cat > squashfs/usr/sbin/BankixCreateSnapshot.sh << EOF
#!/bin/bash
echo "Snapshot erstellen"
echo "=================="
echo
echo "1. Alle Anwendungen schließen!"
echo "2. Schreibschutzschalter am USB-Stick (sofern vorhanden) auf 'offen' stellen!"
echo
read -r -p "Snapshot jetzt erstellen? [j/N] " questionResponse
if [[ \$questionResponse = [jJ] ]]
then
	echo
	sudo apt-get -y clean
	sudo blockdev --setrw \$(findmnt -n -o SOURCE --mountpoint /cdrom)
	sudo mount -o remount,rw /cdrom
	sudo mksquashfs / /cdrom/casper/filesystem_new.squashfs -ef /excludes -wildcards -comp lz4 -Xhc
	sudo rm -f /cdrom/filesystem_old.squashfs
	sudo mv /cdrom/casper/filesystem.squashfs /cdrom/filesystem_old.squashfs
	sudo mv /cdrom/casper/filesystem_new.squashfs /cdrom/casper/filesystem.squashfs
	sudo sync
	sudo mount -o remount,ro /cdrom
	echo
	echo "Das System muss heruntergefahren werden! Aktivieren Sie anschließend den mechanischen Schreibschutzschalter und starten neu. Bitte Taste druecken!"
	read dummy
	sudo shutdown -P now
else
	echo
    echo "Es wurde kein Snapshot erstellt!"
    read dummy
fi
EOF
chmod +x squashfs/usr/sbin/BankixCreateSnapshot.sh

mkdir squashfs/etc/skel/Desktop/
cat > squashfs/etc/skel/Desktop/BankixCreateSnapshot.desktop << EOF
[Desktop Entry]
Encoding=UTF-8
Name=Snapshot erstellen
Exec=/usr/sbin/BankixCreateSnapshot.sh
Type=Application
Terminal=true
Icon=/usr/share/icons/Humanity/actions/48/document-save.svg
EOF
chmod +x squashfs/etc/skel/Desktop/BankixCreateSnapshot.desktop

cp squashfs/usr/share/applications/lxqt-config-monitor.desktop squashfs/etc/skel/Desktop/
cp squashfs/usr/share/applications/firefox.desktop squashfs/etc/skel/Desktop/
cp squashfs/usr/share/applications/upg-apply.desktop squashfs/etc/skel/Desktop/


# Echtzeituhr: Lokalzeit anstatt UTC verwenden für Dual-Boot mit Windows
echo "0.0 0 0" > squashfs/etc/adjtime
echo "0" >> squashfs/etc/adjtime
echo "LOCAL" >> squashfs/etc/adjtime

#### System bauen #### END ######


#### Iso erzeugen #### BEGIN ####
cp squashfs/boot/initrd.img-* iso/casper/initrd.lz
cp squashfs/boot/vmlinuz-* iso/casper/vmlinuz

umount squashfs/dev/pts squashfs/dev squashfs/proc squashfs/sys /mnt

#mv squashfs/etc/resolv.conf.orig squashfs/etc/resolv.conf
chroot squashfs/ mv /etc/resolv.conf.original /etc/resolv.conf
chroot squashfs/ mv /etc/apt/sources.list.original /etc/apt/sources.list

mksquashfs squashfs iso/casper/filesystem.squashfs -noappend -comp lz4 -Xhc
genisoimage -cache-inodes -r -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o live.iso -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot iso

isohybrid -u live.iso

#### Iso erzeugen ####  END  ######
date
echo
