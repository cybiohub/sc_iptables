# Bloquer le trafic provenant de pays spécifiques
---
Pour utiliser les options pour autoriser/bloquer certains pays avec "40-iptables", vous devez appliquer les étapes qui suivent.

# Installation de GeoIP pour iptables

1. Procéder à l'installation des modules xt_tables supplémentaires, qui inclus le module xt_geoip qui sera nécessaire pour iptables.

```bash
apt-get install xtables-addons-common
```

2. Ajuster les permissions d'exécution sur le script "_xt_geoip_build_". Ce script sera nécessaire plus tard pour générer la base de données des pays.

```bash
chmod 700 /usr/lib/xtables-addons/xt_geoip_build
```

</br>

## Activation du module xt_geoip

Pour activer manuellement le module xtables geoip.

```bash
modprobe xt_geoip
```

Pour activer automatiquement le module xtables geoip à chaque démarrage.

```bash
echo "xt_geoip" > /etc/modules-load.d/xt_geoip.conf   
```

## Validation

Confirmer maintenant que le module est bien pris en charge par le noyau.

```bash
lsmod | grep ^xt_geoip
	xt_geoip               16384  0
```
ou encore
```bash
cat /proc/net/ip_tables_matches | grep geoip
	geoip
```

</br>

## Installation de la base de données GeoIP

Procédons à l'installation des outils pour générer la base de données GeoIP. 

```bash
apt-get install geoip-bin geoip-database
```

**geoip-bin**: IP lookup command line tools that use the GeoIP library.

**geoip-database**: IP lookup command line tools that use the GeoIP library (country database).

</br>

## Mécanisme de mise à jour

Nous allons gérérer pour une première fois la base de données et mettre en place une mécanique pour la maintenir à jour.

1. Faites la création du répertoire de destination de la base de données.

```bash
mkdir /usr/share/xt_geoip
```

2. Puis l'installation des dépendances nécessaires au script de mise à jour des données de géolocalisation.

```bash
apt-get install libtext-csv-xs-perl libmoosex-types-netaddr-ip-perl
```

3. Faites la création du script "_geo-update.sh_" pour générer la base de données des pays sous /usr/sbin/.

```bash
vim /usr/sbin/geo-update.sh
```

```bash
#! /bin/bash
#set -x

# #################################################################
# ## VARIABLES
MON=$(date +"%m")
YR=$(date +"%Y")

# #################################################################
# ## FUNCTIONS
function checkPackage() {
 REQUIRED_PKG="${1}"
 PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG 2>&1 | grep "install ok installed")
 if [ "" = "$PKG_OK" ]; then
   echo "xt_geoip is not configured. Missing package xtables-addons-common"
   exit 0
 fi
}

# #################################################################
# ## EXECUTION

checkPackage "xtables-addons-common"

# ## Downloading.
wget https://download.db-ip.com/free/dbip-country-lite-"${YR}"-"${MON}".csv.gz -O /usr/share/xt_geoip/dbip-country-lite.csv.gz
gunzip /usr/share/xt_geoip/dbip-country-lite.csv.gz

# ## Generate.
# ## 18.04
/usr/lib/xtables-addons/xt_geoip_build -D /usr/share/xt_geoip/ -S /usr/share/xt_geoip/
rm /usr/share/xt_geoip/dbip-country-lite.csv

# ## Exit.
exit 0

# ## END
```


```bash
chmod 700 /usr/sbin/geo-update.sh
```

4. Lancer le script pour une première fois manuellement pour générer la base de donnée une première fois.

```bash
/usr/sbin/geo-update.sh
```

Faites une vérification que les fichiers de pays sont présent.

```bash
ls /usr/share/xt_geoip/
```

Vous devriez voir des fichiers avec l'extension .iv4 et .iv6.

5.  Pour automatiser la base de données de GeoIP, ajouter simplement ce script dans une tâche cron.

```bash
vim /etc/cron.d/geoip

	30 19 * * * root /usr/sbin/geo-update.sh
```

# Configurer le GeoIP dans 40-iptables
---

Rechercher la section "EXTRA PROTECTION"

Two letter country code ISO-3166



## Allowed countries.
Enable (1) or Disable (0).
declare -ir GEOIPALLOW=0

Declare country (Two letter country code ISO-3166).
declare -r allowCountry='CA'

## Denied countries.
Enable (1) or Disable (0).
declare -ir GEOIPDENY=1

Declare country (Two letter country code ISO-3166).
declare -r denyCountry='DE,AL,BG,BJ,BR,CZ,EE,GE,GH,HR,IN,IR,KP,KR,PL,RS,RU,SC,TG,UA,UG,UY,ZA,ZM'

