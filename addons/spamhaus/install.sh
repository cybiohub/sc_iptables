#! /bin/bash
#set -x
# * **************************************************************************
# *
# * Creation:           (c) 2004-2022  Cybionet - Ugly Codes Division
# *
# * File:               install.sh
# * Version:            1.0.0
# *
# * Comment:            Tool to configure install of Spamhaus for iptables.
# *
# * Creation: February 25, 2022
# * Change:   February 26, 2022
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


# ############################################################################################
# ## FUNCTIONS

function shUpd() {
 echo -e "\n\e[34m[SCRIPT]\e[0m"
 echo -e "\tCopy spamhaus.sh script to his destination (/usr/sbin/)."

 cp ./bin/spamhaus.sh /usr/sbin/spamhaus.sh
 chmod 500 /usr/sbin/spamhaus.sh

 # ## Launch the script for the first time to generate the list.
 # ## Restriction: Absolutely need xt_geoip module for iptables.
 echo -e "\n\e[34m[DATABASE]\e[0m"
 echo -e "\tPopulate Spamhaus drop list with IPv4 netblocks allocated."
 if [ -f '/usr/sbin/spamhaus.sh' ]; then
   /usr/sbin/spamhaus.sh
 else
   echo -e "\n\e[31mERROR: The Spamhaus script (spamhaus.sh) is missing.\e[0m"
 fi
}

function checkPackage() {
 APPDEP="${1}"
 if ! dpkg-query -s "${APPDEP}" > /dev/null 2>&1; then
   echo -e "\e[33;1;208mWARNING:\e[0m Spamhaus is not configured. Missing package ${APPDEP}."
   echo -e "\tInstall the missing package with this command: apt-get install ${APPDEP}"
   exit 0
 fi
}


# ############################################################################################
# ## EXECUTION

checkPackage 'ipset'
shUpd

echo -e "\n\e[33m[FINISH]\e[0m"

# ## Exit
exit 0

# ## END
