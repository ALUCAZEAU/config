Date: 2019-09-28 15:25
Author: Alexandre LUCAZEAU
Email: lucazeau.alexandre@gmail.com
Title: Mise en place du firewall
Slug: 
Tags: 
Category:

iptables.sh : script initialisant le firewall et contenant les regles de base.

Etape 1 : initialisation
------------------------
exécuter iptables.sh

Etape 2 : Sauvegarder les regles au format iptables
---------------------------------------------------
iptables-save > /etc/iptables.rules

Etape 3 : Créer le fichier de service systemd
---------------------------------------------
    ```bash
    cat /etc/systemd/system/iptables.service
    [Unit]
    Description=Firewall
    After=network.target

    [Service]
    Type=oneshot
    RemainAfterExit=yes
    ExecStart=/bin/sh -c "/sbin/iptables-restore < /etc/iptables.rules"

    [Install]
    WantedBy=multi-user.target

Etape 4 : Activer le nouveau service
------------------------------------
systemctl enable iptables.service

Etape 5 : Redémarrer le firewall
--------------------------------
systemctl restart iptables.service
