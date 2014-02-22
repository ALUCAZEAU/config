#!/bin/bash
/etc/init.d/fail2ban stop
echo Setting firewall rules...
#
# config de base
#
# Je veux pas de spoofing

if [ -e /proc/sys/net/ipv4/conf/all/rp_filter ]
then
	for filtre in /proc/sys/net/ipv4/conf/*/rp_filter
	do
	        echo 1 > $filtre
	done
fi

# Vider les tables actuelles
iptables -t filter -F
iptables -t filter -X
echo - Vidage : [OK]

# Autoriser SSH
iptables -t filter -A INPUT -p tcp --dport 1234 -j ACCEPT
echo - Autoriser SSH : [OK]

# Ne pas casser les connexions etablies
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
echo - Ne pas casser les connexions établies : [OK]

# Interdire toute connexion entrante
iptables -t filter -P INPUT DROP
iptables -t filter -P FORWARD DROP
echo - Interdire toute connexion entrante : [OK]

# Interdire toute connexion sortante
#iptables -t filter -P OUTPUT DROP
#echo - Interdire toute connexion sortante : [OK]

# Autoriser les requetes DNS, FTP, HTTP, NTP (pour les mises a jour)
#iptables -t filter -A OUTPUT -p tcp --dport 21 -j ACCEPT
#iptables -t filter -A OUTPUT -p tcp --dport 80 -j ACCEPT
#iptables -t filter -A OUTPUT -p udp --dport 123 -j ACCEPT
#echo - Autoriser les requetes DNS, FTP, HTTP, NTP : [OK]

# Autoriser loopback
iptables -t filter -A INPUT -i lo -j ACCEPT
iptables -t filter -A OUTPUT -o lo -j ACCEPT
echo - Autoriser loopback : [OK]

# Autoriser ping
iptables -t filter -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
#iptables -t filter -A INPUT -p icmp -j ACCEPT
#iptables -t filter -A OUTPUT -p icmp -j ACCEPT
echo - Autoriser ping : [OK]

# Gestion des connexions entrantes autorisées
#
# iptables -t filter -A INPUT -p <tcp|udp> --dport <port> -j ACCEPT

# HTTP
iptables -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 443 -j ACCEPT
echo - Autoriser serveur http : [OK]

iptables -t filter -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 53 -j ACCEPT
iptables -t filter -A INPUT -p udp --dport 53 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 53 -j ACCEPT
echo - Autoriser serveur DNS : [OK]

# FTP
iptables -t filter -A INPUT -p tcp --dport 20 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 21 -j ACCEPT
iptables -t filter -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
echo - Autoriser serveur FTP : [OK]

# Mail
iptables -t filter -A INPUT -p tcp --dport 25 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 110 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 143 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 25 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 110 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 143 -j ACCEPT
echo - Autoriser serveur Mail : [OK]


# rejeter les fausses connex pretendues s'initialiser et sans syn
iptables -A INPUT -p tcp ! --syn -m state --state NEW,INVALID -j REJECT

# Syn-Flood
iptables -A FORWARD -p tcp --syn -m limit --limit 1/second -j ACCEPT
iptables -A FORWARD -p udp -m limit --limit 1/second -j ACCEPT
echo - Limiter le Syn-Flood : [OK]

# Spoofing
iptables -N SPOOFED
iptables -A SPOOFED -s 127.0.0.0/8 -j DROP
iptables -A SPOOFED -s 10.0.0.0/8 -j DROP
iptables -A SPOOFED -s 62.4.0.0/16 -j DROP
echo - Bloquer le Spoofing : [OK]

iptables -A INPUT -p tcp --dport 1234 -m recent --update --seconds 60 --hitcount 4 --name SSH -j DROP
iptables -A INPUT -p tcp --dport 1234 -m recent --set --name SSH
iptables -A INPUT -p tcp --dport 1234 -j ACCEPT
iptables -A INPUT -p tcp --dport 1234 --jump DROP
echo - Bloquage des connexions ssh apres 4 tentatives echouees [OK]


# Par curiosite, on peut tracer les demandes de connexions en provenance de l'exterieur
# Traces disponibles dans le fichier /var/log/iptables.log
iptables -A INPUT -m state --state NEW -j LOG
# Idem pour les demandes faites localement vers l'extérieur (vers, troyan, ...)
iptables -A OUTPUT -m state --state NEW -j LOG

/etc/init.d/fail2ban start
echo Firewall mis a jour avec succes !
