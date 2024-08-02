#! /bin/bash
#set -x
# * **************************************************************************
# *
# * Author:             (c) 2004-2024  Cybionet - Ugly Codes Division
# *
# * File:               install.sh
# * Version:            1.1.2
# *
# * Description:        Tool to configure install TOR bulk next list for iptables.
# *
# * Creation: September 07, 2021
# * Change:   August 02, 2024
# *
# * **************************************************************************
# * chmod 500 install.sh
# ****************************************************************************


# #################################################################
# ## CUSTOM VARIABLES

# ## Do not put the trailing slash.
rulesLocation='/root/running_scripts/iptables'


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
# ## EXECUTION

# ## Installing the ipset package.
function ipsetIns() {
 if ! dpkg-query -s ipset > /dev/null 2>&1; then
   echo -e "\e[34;1;208mINFORMATION:\e[0m Installing ipset package."
   apt-get install ipset
 fi
}

# ## Create a place for rules if they don't exist.
function torLocation() {
 if [ ! -d "${rulesLocation}" ]; then
   mkdir -p "${rulesLocation}"
 fi
}

# ##
function copyApp() {
 cp ./sbin/generatetorbulkexit.sh "${rulesLocation}"/
 chmod 500 "${rulesLocation}"/generatetorbulkexit.sh
}


# ##
function ipsetUpd() { 
 # ## Download Tor bulk exit list.
 wget -T3 -q https://check.torproject.org/torbulkexitlist -O "${rulesLocation}"/torbulkexit.ip || rm -f "${rulesLocation}"/torbulkexit.ip

 # ## Populate the Tor node.
 shTorList=$(ipset list tor-nodes 2>/dev/null | wc -l)

 if [ "${shTorList}" -le 2 ]; then
   ipset create tor-nodes iphash
 fi

 # ## Check if the Spamhaus IP list file exist.
 if [ ! -f "${rulesLocation}"/torbulkexit.ip ]; then
   touch "${rulesLocation}"/torbulkexit.ip
 fi

 # ## Populate TORIP chain.
 cat "${rulesLocation}"/torbulkexit.ip | while read -r TORIP; do ipset -q -A tor-nodes "${TORIP}"; done

 # ## Copie cron file for torbulkexit.
 cp ./cron.d/torlistupdate /etc/cron.d/
}


# #################################################################
# ## EXECUTION

ipsetIns
torLocation
copyApp
ipsetUpd


# #################################################################
# ## EXAMPLE

# ## Example.
echo -e "\n\e[34m[EXAMPLE]\e[0m"
echo -e '\t iptables -N TORDENY'
echo -e '\t iptables -A INPUT -j TORDENY'
echo -e '\t iptables -A TORDENY -m set --match-set tor-nodes src -j LOG --log-prefix "IPTABLES: TOR "'
echo -e '\t iptables -A TORDENY -m set --match-set tor-nodes src -j DROP'


# ## Exit 0
exit 0

# ## END
