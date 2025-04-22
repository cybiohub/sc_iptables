#! /bin/bash
#set -x
# * **************************************************************************
# *
# * Author:             (c) 2004-2025  Cybionet - Ugly Codes Division
# *
# * File:               install.sh
# * Version:            1.0.4
# *
# * Description:        Tool to configure install KillNet DDoS list for iptables.
# *
# * Creation: February 17, 2023
# * Change:   January 10, 2025
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
  echo -e "\n\n\n\e[33mCAUTION: This script must be run with sudo or as root.\e[0m\n"
  exit 0
else
  echo -e "\n\e[34m${appHeader}\e[0m"
  printf '%.s─' $(seq 1 "$(tput cols)")
fi


# #################################################################
# ## EXECUTION

# ## Installing the 'ipset' package.
function ipsetIns() {
 if ! dpkg-query -s ipset > /dev/null 2>&1; then
   echo -e "\e[34;1;208mINFORMATION:\e[0m Installing 'ipset' package."
   apt-get install ipset
 else
   echo -e "\nChecking if 'ipset' package is installed \t\t[\e[32mOK\e[0m]"
 fi
}

# ## Create a place for rules if they don't exist.
function knLocation() {
 if [ ! -d "${rulesLocation}" ]; then
   mkdir -p "${rulesLocation}"
 else
   echo -e "Checking if '${rulesLocation}/' exist \t[\e[32mOK\e[0m]"
 fi
}

# ## Copy of the 'KillNet DDoS' generator script.
function copyApp() {
 echo -e "Copy of the 'killnet' generator script \t\t\t[\e[32mOK\e[0m]"
 cp ./sbin/generatekillnet.sh /usr/sbin/
 chmod 500 /usr/sbin/generatekillnet.sh
 
 ln -sf /usr/sbin/generatekillnet.sh "${rulesLocation}/generatekillnet.sh"
}

# ## Download and populate the KillNet DDoS node for the first time.
function ipsetUpd() {
 # ## Download KillNet DDoS list.
 echo -e -n "Downloading the killnet file list "
 wget -t"${wgetRetry}" -T"${wgetTimeout}" -q -O - https://raw.githubusercontent.com/securityscorecard/SSC-Threat-Intel-IoCs/master/KillNet-DDoS-Blocklist/proxylist.txt -O "${rulesLocation}"/killnet.ip || rm -f "${rulesLocation}"/killnet.ip

 if [ -f "${rulesLocation}/killnet.ip" ]; then
   logger -t killnet -p user.info "Download completed."
   echo -e "\t\t\t[\e[32mOK\e[0m]"
 else
   echo -e "\t\t\t[\e[31mFAIL\e[0m]"
   echo "${rulesLocation}/killnet.ip"
   exit 1
 fi

 # ## Populate the KillNet DDoS node.
 echo -e -n "Populate the killnet node "
 shKnList=$(ipset list killnet-nodes | wc -l)

 if [ "${shKnList}" -le 2 ]; then
   ipset create killnet-nodes iphash
 fi

 # ## Check if the KillNet DDoS IP list file exists.
 if [ ! -f "${rulesLocation}"/killnet.ip ]; then
   touch "${rulesLocation}"/killnet.ip
 fi

 # ## Populate KNDENY chain.
 cat "${rulesLocation}"/killnet.ip | awk -F ":" '{print $1}' | while read -r KNIP;do ipset -q -A killnet-nodes "${KNIP}"; done
 echo -e "\t\t\t\t[\e[32mOK\e[0m]"
}

# ## Deploy the 'cron' script to automate the update of the killnet list.
function ipsetCron() {
 # ## Copying the cron file for KillNet DDoS.
 echo -e "Copy the 'cron' for the killnet update \t\t\t[\e[32mOK\e[0m]\n"
 cp ./cron.d/killnetupdate /etc/cron.d/
}


# #################################################################
# ## EXECUTION

ipsetIns
knLocation
copyApp
ipsetUpd
ipsetCron


# #################################################################
# ## INSTRUCTIONS


ipset list | grep Named | grep killnet-nodes
echo -e "\n\n"

# ## Example of using the killnet-nodes.
echo -e "\nAdd these lines to the custom rules file."
echo -e '\t iptables -N KNDENY'
echo -e '\t iptables -A INPUT -j KNDENY'
echo -e '\t iptables -A KNDENY -m set --match-set killnet-nodes src -j LOG --log-prefix "IPTABLES: KILLNET "'
echo -e '\t iptables -A KNDENY -m set --match-set killnet-nodes src -j DROP\n'


# ## Exit 0
exit 0

# ## END
