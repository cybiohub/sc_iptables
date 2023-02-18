#! /bin/bash
#set -x
# * **************************************************************************
# *
# * Author:             (c) 2004-2023  Cybionet - Ugly Codes Division
# *
# * File:               install.sh
# * Version:            1.0.0
# *
# * Description:        Tool to configure install KillNet DDoS list for iptables.
# *
# * Creation: February 17, 2023
# * Change:   
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

# ## Download parameters.
wgetRetry=3
wgetTimeout=3


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
function knLocation() {
 if [ ! -d "${rulesLocation}" ]; then
   mkdir -p "${rulesLocation}"
 fi
}

# ##
function copyApp() {
 cp ./bin/generatekillnet.sh "${rulesLocation}"/
 chmod 500 "${rulesLocation}"/generatekillnet.sh
}

# ##
function ipsetUpd() { 
 # ## Download KillNet DDoS list.
 wget -t"${wgetRetry}" -T"${wgetTimeout}" -q -O - https://raw.githubusercontent.com/securityscorecard/SSC-Threat-Intel-IoCs/master/KillNet-DDoS-Blocklist/proxylist.txt -O "${rulesLocation}"/killnet.ip || rm -f "${rulesLocation}"/killnet.ip 

 logger -t killnet -p user.info "Download complete."

 # ## Populate the KillNet node.
 shKnList=$(ipset list killnet-nodes | wc -l)

 if [ "${shKnList}" -le 2 ]; then
   ipset create killnet-nodes iphash
 fi

 # ## Check if the Spamhaus IP list file exist.
 if [ ! -f "${rulesLocation}"/killnet.ip ]; then
   touch "${rulesLocation}"/killnet.ip
 fi

 # ## Populate KNIP chain.
 cat "${rulesLocation}"/killnet.ip | awk -F ":" '{print $1}' | while read -r KNIP;do ipset -q -A killnet-nodes "${KNIP}"; done

 # ## Copie cron file for KillNet DDoS.
 cp ./cron.d/killnetupdate /etc/cron.d/
}


# #################################################################
# ## EXECUTION

ipsetIns
knLocation
copyApp
ipsetUpd


# #################################################################
# ## EXAMPLE

# ## Example.
echo -e "\n\e[34m[EXAMPLE]\e[0m"
echo -e '\t iptables -N KNDENY'
echo -e '\t iptables -A INPUT -j KNDENY'
echo -e '\t iptables -A KNDENY -m set --match-set killnet-nodes src -j LOG --log-prefix "IPTABLES: KILLNET "'
echo -e '\t iptables -A KNDENY -m set --match-set killnet-nodes src -j DROP'


# ## Exit 0
exit 0

# ## END
