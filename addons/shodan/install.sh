#! /bin/bash
#set -x
# * **************************************************************************
# *
# * Author:             (c) 2004-2024  Cybionet - Ugly Codes Division
# *
# * File:               install.sh
# * Version:            1.0.0
# *
# * Description:        Tool to configure install Shodan deny list for iptables.
# *
# * Creation: August 05, 2024
# * Change:   
# *
# * **************************************************************************
# * chmod 500 install.sh
# ****************************************************************************


# #################################################################
# ## CUSTOM VARIABLES

# ## Do not put the trailing slash.
rulesLocation='/root/running_scripts/iptables'

# ## Force configuration of the script.
# ## Value: enabled (true), disabled (false).
declare -r isConfigured='false'


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
  echo -e "\n\n\n\e[33mCAUTION: This script must be run with sudo or as root.\e[0m\n"
  exit 0
else
  echo -e "\n\e[34m${appHeader}\e[0m"
  printf '%.s─' $(seq 1 "$(tput cols)")
fi

# ## Check if the script is configured.
if [ "${isConfigured}" == 'false' ] ; then
  echo -n -e '\e[38;5;208mWARNING: Customize the settings to match your environment. Then set the "isConfigured" variable to "true".\n\e[0m'
  exit 0
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
function shoLocation() {
 if [ ! -d "${rulesLocation}" ]; then
   mkdir -p "${rulesLocation}"
 else
   echo -e "Checking if '${rulesLocation}/' exist \t[\e[32mOK\e[0m]"
 fi
}

# ## Copy of the 'Shodan deny list' generator script.
function copyApp() {
 echo -e "Copy of the 'Shodan list' generator script \t\t\t[\e[32mOK\e[0m]"
 cp ./sbin/generateshodan.sh "${rulesLocation}"/
 chmod 500 "${rulesLocation}"/generateshodan.sh
}

# ## Populate the Shodan node for the first time.
function ipsetUpd() {
 # ## Copy Shodan list.
 cp ./list/shodan.ip "${rulesLocation}"/
 
 if [ -f "${rulesLocation}/shodan.ip" ]; then
   logger -t shodan -p user.info "Copy completed."
   echo -e "\t\t\t[\e[32mOK\e[0m]"
 else
   echo -e "\t\t\t[\e[31mFAIL\e[0m]"
   echo "${rulesLocation}/shodan.ip"
   exit 1
 fi

 # ## Populate the Shodan node.
 echo -e -n "Populate the Shodan node "
 shoList=$(ipset list shodan-nodes | wc -l)

 if [ "${shoList}" -le 2 ]; then
   ipset create shodan-nodes iphash
 fi

 # ## Check if the Shodan IP list file exists.
 if [ ! -f "${rulesLocation}"/shodan.ip ]; then
   touch "${rulesLocation}"/shodan.ip
 fi

 # ## Populate chain.
 cat "${rulesLocation}"/shodan.ip | awk -F ":" '{print $1}' | while read -r SHODANIP;do ipset -q -A shodan-nodes "${SHODANIP}"; done
 echo -e "\t\t\t\t[\e[32mOK\e[0m]"
}


# #################################################################
# ## EXECUTION

ipsetIns
shoLocation
copyApp
ipsetUpd


# #################################################################
# ## INSTRUCTIONS

ipset list | grep Named | grep shodan-nodes
echo -e "\n\n"

# ## Example of using the shodan-nodes node.
echo -e "\nAdd these lines to the custom rules file."
echo -e '\t iptables -N SHODAN'
echo -e '\t iptables -A INPUT -j SHODAN'
echo -e '\t iptables -A SHODAN -m set --match-set shodan-nodes src -j LOG --log-prefix "IPTABLES: SHODAN "'
echo -e '\t iptables -A SHODAN -m set --match-set shodan-nodes src -j DROP\n'


# ## Exit 0
exit 0

# ## END
