#! /bin/bash
#set -x
# * **************************************************************************
# *
# * Creation:           (c) 2004-2022  Cybionet - Ugly Codes Division
# *
# * File:               install.sh
# * Version:            1.0.0
# *
# * Comment:            Tool to configure install Geoip for iptables.
# *
# * Creation: September 07, 2021
# * Change:   February 23, 2022
# *
# * **************************************************************************
# * chmod 500 install.sh
# ****************************************************************************


#############################################################################################
# ## VARIABLES

# ## Retrieval of the current year.
appYear=$(date +%Y)

# ## Application informations.
appHeader="(c) 2004-${appYear}  Cybionet - Ugly Codes Division"


#############################################################################################
# ## VERIFICATION

# ## Check if the script are running with sudo or under root user.
if [ "${EUID}" -ne 0 ] ; then
  echo -e "\n\e[34m${appHeader}\e[0m"
  printf '%.s─' $(seq 1 "$(tput cols)")
  echo -e "\n\n\n\e[33mCAUTION: This script must be run with sudo or as root.\e[0m"
  exit 0
else
  echo -e "\n\e[34m${appHeader}\e[0m"
  printf '%.s─' $(seq 1 "$(tput cols)")
fi


# #################################################################
# ## FUNCTIONS

# ########################
# ## GEOIP

# ## Installing the geoip package and its database.
function geoipIns() {
 apt-get install geoip-bin geoip-database
}

# ## Installing geoip dependencies.
function geoipDep() {
 apt-get install libtext-csv-xs-perl libmoosex-types-netaddr-ip-perl
}

function geoipUpd() {
 #wget 
 cp ./bin/geo-update.sh /usr/sbin/geo-update.sh
 chmod 500 /usr/sbin/geo-update.sh

 # ## Launch the script for the first time to generate the list.
 # ## Restriction: Absolutely need xt_geoip module for iptables.
 /usr/sbin/geo-update.sh
}

function geoipCron() {
 #wget
 cp ./cron.d/geoipupdate /etc/cron.d/geoipupdate

# vim /etc/cron.d/geoipupdate
#
#	# ## Geoip
#	30 19 * * * root /usr/sbin/geo-update.sh >/dev/null 2>&1
}


# ########################
# ## XT_GEOIP

function xtGeoipDep() {
 # ## xt_tables module for iptables.
 echo -e "\tInstallation of xtables-addons-common package."

 apt-get install xtables-addons-common
 echo 'xt_geoip' > /etc/modules-load.d/xt_geoip.conf
 echo -e "\e[38;208mWARNING: A system restart is required.\e[0m"

 if [ -f '/usr/lib/xtables-addons/xt_geoip_build' ]; then
   chmod 700 /usr/lib/xtables-addons/xt_geoip_build
 else
   echo -e '\e[31;208mERROR: xtables-addons-common package is required.\e[0m'
   exit 1
 fi

 # ## Manual loading of the xt_geoip module.
 modprobe xt_geoip
}

function xtGeoipRep() {
 if [ ! -d "/usr/share/xt_geoip" ]; then
   echo -e "\tCreation of Geoip directory."
   mkdir /usr/share/xt_geoip
 fi
}

function ccFilesCheck() {
 ccFiles=$(find /usr/share/xt_geoip/ -type f | wc -l)

 if [ ! "${ccFiles}" -gt 10 ]; then
   echo -e '\e[31;208mERROR: Missing Country Code database files.\e[0m\ Launch /usr/sbin/geo-update.sh script to populate database.'
   exit 1
 fi
}

function xtGeoipCheck() {
 xtModule=$(grep geoip /proc/net/ip_tables_matches)
 if [ ! "${xtModule}" == "geoip" ]; then
   echo -e '\e[31;208mERROR: xt_geoip module not loaded.\e[0m\ Check with "lsmod | grep xt_goip".'
 fi
}


# #################################################################
# ## EXECUTION

# ## Geoip installation.
echo -e "\n\e[34m[GEOIP]\e[0m"
geoipInstall
geoipDep

# ## XT_Geoip installation.
echo -e "\n\e[34m[XT_GEOIP]\e[0m"
xtGeoipDep
xtGeoipRe
xtGeoipCheck

# ## Update Mecanism
echo -e "\n\e[34m[GEOIP DATABASE]\e[0m"
geoipUpd
geoipCron
ccFilesCheck


# #################################################################
# ## EXAMPLE

# ## Example.
echo -e "\n\e[34m[EXAMPLE]\e[0m"
echo 'When adjusting the country code, use these two lines. The first line for logs and the second for dropping.'
echo 'iptables -A GEOIPDENY -m geoip --source-country RU -j LOG --log-prefix "IPTABLES: Country Denied: RU "'
echo 'iptables -A GEOIPDENY -m geoip --source-country RU -j DROP'


# ## Exit.
exit 0

# ## END
