# *
# * Location: /usr/sbin/ip6tables.sh
# *
# *  vim /etc/systemd/system/ip6tables-rules.service
# *
# * If you make a modification in this script run the commands.
# *
# * systemctl daemon-reload
# * systemctl restart ip6tables-rules.service


CYBIONET - MISE EN SERVICE DES REGLES IPV4 ET IPV6 D'IPTABLES
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Procédures pour la mise en service des règles iptables sur des serveurs Ubuntu 16.04/18.04 et Debian 9.x.


Service Iptables IPv4
=========================

1. Déploiement de l'exécutable pour le service.

  mv iptables.sh /usr/sbin/
  ln -sf /usr/sbin/iptables.sh /root/running_scripts/iptables/iptables.sh
  chmod 700 /usr/sbin/iptables.sh

2. Ajout de la configuration pour le service iptables.

  vim /etc/systemd/system/iptables-rules.service

[Unit]
Description=IPTables Rules daemon
After=network.target
#ConditionPathExists=/usr/sbin/

[Service]
#Type=simple
ExecStart=/usr/sbin/iptables.sh
#Restart=on-failure

[Install]
WantedBy=default.target
#WantedBy=multi-user.target


3. Rafraichissemenet des configurations de systemctl.

  systemctl daemon-reload

4. Activation du service au redémarrage.

Les fichiers dans /etc/systemd/system/default.target.wants/ sont ceux qui doivent être exécuté au démarrage.

  systemctl enable iptables-rules.service

5. Modifier le fichier iptables.sh pour répondre à vos exigences.

  vim /usr/sbin/iptables.sh

6. Exécution de notre service iptables.sh.

  systemctl start iptables-rules.service
  systemctl status iptables-rules.service
  systemctl stop iptables-rules.service

7. Vérification.

  iptables -L

ou encore

  iptables-save



Service Iptables IPv6
=======================

1. Déploiement de l'exécutable pour le service.

  mv ip6tables.sh /usr/sbin/
  ln -sf /usr/sbin/ip6tables.sh /root/running_scripts/iptables/ip6tables.sh
  chmod 700 /usr/sbin/ip6tables.sh

2. Ajout de la configuration pour le service ip6tables.

  vim /etc/systemd/system/ip6tables-rules.service

[Unit]
Description=IP6Tables Rules daemon
After=network.target
#ConditionPathExists=/usr/sbin/

[Service]
#Type=simple
ExecStart=/usr/sbin/ip6tables.sh
#Restart=on-failure

[Install]
WantedBy=default.target
#WantedBy=multi-user.target


3. Rafraichissemenet des configurations de systemctl.

  systemctl daemon-reload

4. Activation du service au redémarrage.

   Les fichiers dans /etc/systemd/system/default.target.wants/ sont ceux qui doivent être exécuté au démarrage.

  systemctl enable ip6tables-rules.service

5. Modifier le fichier iptables.sh pour répondre à vos exigences.

  vim /usr/sbin/ip6tables.sh

6. Exécution de notre service ip6tables.sh.

  systemctl start ip6tables-rules.service
  systemctl status ip6tables-rules.service

  systemctl stop ip6tables-rules.service

7. Vérification.

  ip6tables -L

ou encore

  ip6tables-save


