---
layout: default
title: ctbankix
---
## einige Details zu ctbankix und ein "Danke schön"


#### Dieses Repository bezieht sich auf [ctbankix-continuation](https://github.com/ctbankix-continuation-team/ctbankix-continuation)

#### vorab:

Alles, was ich hier schreibe, schreibe ich nach bestem Wissen und Gewissen. Irrtümer, Mißverständnisse und Überschätzung meiner eignen Kenntnisse sind jedoch immer möglich, denken Sie daran! 

(I do my best, but, please, read everthing here with a "grain of salt" :-)


#### raison d'être : ctbankix verstehen und Komfortmerkmale einbauen

Als Leser der [ct](https://www.heise.de/ct/) war ich 2008 auf [ctbankix](https://www.heise.de/ct/artikel/Sicheres-Online-Banking-mit-Bankix-284099.html) aufmerksam geworden und nutze es seitdem kontinuierlich. 2014 titelte die ct: "[Sicher wie Fort Knox](https://www.heise.de/select/ct/archiv/2014/7/seite-146)". Skepsis ist bei solchen Aussagen im IT-Bereich immer angebracht, aber Fakt: Ist es einem Gegenüber wirklich gelungen, auf meinem Rechner eine Schadsoftware zu platzieren, ist die Wahrscheinlichkeit sehr groß, dass beim nächsten Start das System dann wieder vollständig so ist, wie ich es bei der letzten Installation hinterlassen hatte. So meine ich, eine verbesserte Sicherheitssituation zu erreichen, besonderes wichtig wenn es um Geld geht (und daraus ist dann ja wohl auch der Name “Bankix” für dieses System entstanden ;-). Der "frische Start" ist auch ein wesentliches Prinzip z.B. von [tails](https://tails.boum.org/), _ctbankix_ ist jedoch wesentlich einfacher aufgebaut, das bereitgestellte Buildscript ist übersichtlich und bietet sich daher für eigene Versuche an.

Immer wieder und in einzelnen Teilen habe ich für mich - meist on the fly - kleine Veränderungen eingebaut, die mir das Leben mit diesem System komfortabler machen. Diese Seite erstelle ich (&nbsp;eher selbstreflexiv&nbsp;) um beim Beschreiben die eingesetzte Software besser zu verstehen sowie meine eigenen Änderungen zu dokumentieren. 



#### Dank dem ctbankix-continuation-team


[dreierlei](https://www.heise.de/forum/c-t/Kommentare-zu-c-t-Artikeln/Sicheres-Online-Banking-mit-Bankix/Weiterentwicklung-ctbankix-auf-Basis-von-Lubuntu-16-04-1-32-Bit/posting-29217674/show/) hat das ctbankix-continuation-Projekt, auf welches ich mich im weiteren hier beziehe,  in Gang gesetzt und geteilt; vielen Dank dafür. Den anderen Aktiven, deren Unterstützung zum Erfolg dieser Version im Speziellen und der Idee des sicheren Datenaustausches im Allgemeinen beiträgt, zolle ich hier ebenfalls meinen Respekt.

#### Was ist ctbankix?

###### Verläßliches OS-Image
ctbankix wird erstellt aus einem Basis-Betriebssystem-Image, welches von einer breiten Öffentlichkeit beobachtet wird und dem wir vertrauen. Zum Zeitpunkt, zu dem ich das hier schreibe, ist aktuell die Quelle: [Lubuntu 20.04.2](http://cdimage.ubuntu.com/lubuntu/releases/20.04.2/release/lubuntu-20.04.2-desktop-amd64.iso). 

Wir holen es von einem vertrauenswürdigen Server und die Authentizität der Ubuntu-Image-Datei wird durch eine Signatur (Hash) versprochen. Ich kann eine Datei, die den Hash des von mir gewählten Images enthält, ebenfalls vom Server der Ersteller herunterladen, dann selbst einen Hash über das bei mir angekommene Paket erzeugen und diesen dann mit dem Hash, der von den Erstellern ermittelt wurde, vergleichen. Das Verfahren ist noch etwas komplizierter und durch gpg abgesichert, es wird in diesem [Tutorial](https://tutorials.ubuntu.com/tutorial/tutorial-how-to-verify-ubuntu) erklärt. 

###### Betriebsmodus: Medien (fast) nicht beschreibbar

Ein wesentlicher Sicherheitsaspekt des ctBankix ist der Betrieb im schreibgeschützten Modus. Ich setze einen USB-Stick mit SDHC-Karten ein, die einen Schreibschutzschalter haben. Wenn der Schalter in der passenden Stellung ist, wird ein Schreibversuch beantwortet mit einer Meldung, dass das Medium nicht beschreibbar sei. Wie sicher dieses Feature ist, kann ich nicht beurteilen. ( ... unten mehr dazu )

###### Kernel: gepatcht und selbstkompiliert - verhindert Zugriff auf Festplatten

Ansonsten ist der Kernel, der zum Einsatz kommt, so verändert, dass auf Festplatten und - so verstehe ich die aktuelle Diskussion - auf NVMe-Speicher nicht zugegriffen werden kann. Somit kann auch auf diesem Wege keine Schadsoftware in das System gelangen. (&nbsp;Letztlich ist das Kernel-Kompilieren die zeitaufwändigste Arbeit beim Neuerstellen eines neuen Sticks.&nbsp;) 

###### ISOLINUX

Es gibt unterschiedliche Bootloader für den Kernel im SYSLINUX-Projekt von Hans Peter Anvim (s.[Wikipedia](https://de.wikipedia.org/wiki/SYSLINUX)). ISOLINUX dient dem Starten des ISO-9660-Dateisystems, SYSLINUX startet FAT-Dateisysteme. 

Nach meiner Erinnerung ( zum Zeitpunkt dieser Doku-Änderung habe ich ctbankix nicht mehr in Bearbeitung und um das jetzt 100% hinzubekommen müsste ich es noch einmal erstellen, aber das ist mir jetzt zuviel Arbeit, ich lebe mit den 98% ) wird das ctbankix mit ISOLINUX erzeugt; hatte ich ein Image mit **cp** oder **dd** auf das Speichermedium geschrieben ( beides sind valide Optionen, Images auf Datenträger wie SDHC-Karten zu schreiben ), wird das entstehende System auf **/dev/sda** als **ISO9660-Dateisystem** gemountet und dieses Dateisystem kann nicht mehr beschrieben werden (siehe: [stackexchange](https://unix.stackexchange.com/questions/26237/iso-file-readonly)). So verhält es sich auch, wenn ich das Image mit kvm in Betrieb nehme: **/dev/sr0 on /cdrom type iso9660**.  (2021-06-23) Wenn ich mit [balenaEdger](https://www.balena.io/etcher/) das Image anlegen, ist der Mount ähnlich: **/dev/sda1 on /cdrom type iso9660**. (Unterschied zu dd: sda <=> sda1).

Ich wiederhole: So erstellte Images sind inhärent durch das Dateisystem gegen Beschreiben geschützt.

###### SYSLINUX: VFAT -> Einsatz mit Schreibschutz -> ausschalten -> Updates speichern

Wird das selbst erstellte Image mittels [UNetbootin](https://unetbootin.github.io/) auf die Speicherkarte geschrieben werden, wird nach meiner Beobachtung (&nbsp;mit der Version 18.04 / 32&nbsp;) ISOLINUX gegen SYSLINUX ausgetauscht und ein solchermassen erstelltes ctBankix ist auf dem Device **/dev/sda1 on /cdrom type vfat** gemountet und die Option, Daten zu schreiben, entsteht. 

Als Schutz gegen Änderungen des Images wird empfohlen, Medien zu nutzen, die einen Schreibschutzschalter haben. Im Laufe der Zeit habe ich immer wieder überprüft, ob dieser korrekt funktioniert, es hat immer geklappt, aber m.E. ist das eine Entscheidung des Kernels, eine Schalterstellung zu respektieren oder nicht. ( ... aber da bin ich nicht ganz sicher ).

Der Schreibschutz kann deaktiviert werden mittels Öffnen des Schreibschutzschalters. So entsteht die Komfort-Möglichkeit, Daten auf dem Trägermedium SDHC-Karte speichern und somit Modifikationen am ctBankix-Image einfach und schnell persistieren zu können. Wenn in dieser Zeit eine Netzwerkverbindung besteht, ist das jedoch gleichzeitig ein Sicherheitsrisiko.  

###### ... mit älterer Hardware / PCs

Meine Wirklichkeit ist nun, dass nur noch eine alte Version des Unetbootin, welche ich auf einem alten Laptop installiert hatte, Images erzeugen kann, die auf älterer Hardware schreibbar gebootet werden können. SDHC-Karten, die ich mit neueren Versionen von Unetbootin beschrieben hatte, konnte ich nicht erfolgreich auf älterer Hardware booten. (&nbsp;Diese Erkenntnis geht auf Erfahrungen zurück, die ich 2018/2019 gesammelt hatte und die mittlerweile überholt sein können.&nbsp;)


