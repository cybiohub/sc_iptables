#! /bin/bash
#set -x
# * **************************************************************************
# *
# * Author:             (c) 2004-2022  Cybionet - Ugly Codes Division
# *
# * File:               install.sh
# * Version:            1.0.1
# *
# * Description:        Tool to configure install of Spamhaus for iptables.
# *
# * Creation: February 25, 2022
# * Change:   March 01, 2022
# *
# * **************************************************************************
# * chmod 500 install.sh
# ****************************************************************************


#############################################################################################
# ## VARIABLES

# ## Path where is located the custom rules file.
declare -r customPath='/root/running_scripts/iptables'

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
 echo -e "\tCopy generatespamhaus.sh script to his destination (/usr/sbin/)."

 cp ./bin/generatespamhaus.sh /usr/sbin/generatespamhaus.sh
 chmod 500 /usr/sbin/generatespamhaus.sh

 # ## Launch the script for the first time to generate the list.
 # ## Restriction: Absolutely need xt_geoip module for iptables.
 echo -e "\n\e[34m[DATABASE]\e[0m"
 echo -e "\tPopulate Spamhaus drop list with IPv4 netblocks allocated."
 if [ -f '/usr/sbin/generatespamhaus.sh' ]; then
   /usr/sbin/generatespamhaus.sh
 else
   echo -e "\n\e[31mERROR: The Spamhaus script (generatespamhaus.sh) is missing.\e[0m"
 fi
}

function checkPackage() {
 if ! dpkg-query -s ipset > /dev/null 2>&1; then
   echo -e "\e[33;1;208mWARNING:\e[0m Spamhaus is not configured. Missing package ipset."
   echo -e "\tInstall the missing package with this command: apt-get install ipset"
   exit 0
 fi
}

function populateIpset() {
 # ## Populate the Spamhaus node.
 shDropList=$(ipset list spamhaus-nodes | wc -l)

 if [ "${shDropList}" -le 2 ]; then
   ipset create spamhaus-nodes nethash
 fi

 # ## Check if the custom path exist. If it does not exist, create it.
 if [ ! -d "${customPath}" ]; then
   mkdir -p "${customPath}"
 fi

 # ## Check if the Spamhaus IP list file exist.
 if [ ! -f "${customPath}"/spamhaus.ip ]; then
   touch "${customPath}"/spamhaus.ip
 fi


 while IFS= read -r SHDROPIP; do echo "${SHDROPIP%?}";
   ipset -q -A spamhaus-nodes "${SHDROPIP}"
 done < "${customPath}"/spamhaus.ip
}

# ############################################################################################
# ## EXECUTION

checkPackage
shUpd
populateIpset

echo -e "\n\e[33m[FINISH]\e[0m"

# ## Exit
exit 0

# ## END
