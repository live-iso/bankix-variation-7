---
layout: default
title: qemu-system-x86_64 
---
## /usr/bin/kvm aka qemu-system-x86_64

für Basics siehe: [Lars Wirzenius](https://blog.liw.fi/posts/kvm-for-ubuntu-iso-testing/)

#### Hinweis: 
auf Debian und Ubunut ruft _/usr/bin/kvm_ qemu-system-x86_64 auf: 

```
exec qemu-system-x86_64 -enable-kvm "$@"
```

Von dieser Komfortfunktion mache ich hier durchgängig Gebrauch.

#### Netzwerk für kvm aktivieren // root

(Ich habe eine zweite Netzwerkkarte in meinem PC. Diese ist einem anderen Netzsegment angeschlossen und wird nicht vom NetworkManager oder netplan verwaltet. Diese zweite Karte nutze ich jetzt für meine virtuellen Maschinen. Wenn nur ein einziger Netzwerkadapter zur Verfügung steht, sieht das dann etwas anders aus.)

```
ip link set dev enp5s0 up
ip tuntap add tap0 mode tap user debianuser
ip link set dev tap0 up
ip link add kvmBridge type bridge
ip link set tap0 master kvmBridge
ip link set enp5s0 master kvmBridge
ip link set kvmBridge up
#
dhclient -v -r kvmBridge
#
echo "Network:" && ip a
```

#### mit sudo kvm starten // completeNetPlusSharedDir.sh
```
kvm –name foo -m 8196 -hda /var/lib/libvirt/mytarget/foo.img -cdrom /home/debianuser/ISOs/live.iso -cpu host -boot d -device e1000,netdev=net0,mac=87:83:17:36:CA:CA -netdev tap,id=net0,ifname=tap0,script=no,downscript=no -smp 2 -vga qxl -fsdev local,security_model=passthrough,id=fsdev0,path=/tmp/share -device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare
```

##### Anmerkung security_model in completeNetPlusSharedDir.sh

In der “nested Virtualization” in Ubuntu 20.04 ( virtuelle Maschine in einer virtuellen 20.04.2-Instanz )ersetze ich
```
security_model=mapped-xattr
```
[wiki.qemu.org/Documentation/9psetup](https://wiki.qemu.org/Documentation/9psetup)
