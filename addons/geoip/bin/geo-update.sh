#! /bin/bash
#set -x
# * **************************************************************************
# *
# * Author:             (c) 2004-2022  Cybionet - Ugly Codes Division
# *
# * File:               geo-update.sh
# * Version:            1.0.1
# *
# * Description:        Tool to populate Geoip databases for iptables.
# *
# * Creation: September 07, 2021
# * Change:   February 28, 2022
# *
# * **************************************************************************
# * chmod 500 geo-update.sh
# ****************************************************************************


# #################################################################
# ## VARIABLES

# ## Formatted date information to download the right database.
MON=$(date +"%m")
YR=$(date +"%Y")

# ## Maximum wait time tolerated to receive the response from the remote server.
declare -i timeOut=5


# #################################################################
# ## FUNCTIONS

osRelease() {
 release=$(lsb_release -r | awk -F " " '{print $2}')

 if [[ "${release:0:2}" =~ ^(16|18)$ ]]; then
   echo -e "\e[31;1;208mERROR:\e[0m Your version of Ubuntu is too old (Ubuntu ${release}). Please use Ubuntu 20.04 and above."
   exit 0
 fi
}

function checkPackage() {
 APPDEP="${1}"
 if ! dpkg-query -s "${APPDEP}" > /dev/null 2>&1; then
   echo -e "\e[31;1;208mERROR:\e[0m Fail to download database. Try to download manually https://download.db-ip.com/free/dbip-country-lite-${YR}-${MON}.csv.gz"
   exit 0
 fi
}


# #################################################################
# ## EXECUTION

# ## Verification.
osRelease
checkPackage 'xtables-addons-common'

# ## Downloading database.
 if ! wget --timeout=${timeOut} https://download.db-ip.com/free/dbip-country-lite-"${YR}"-"${MON}".csv.gz -O /usr/share/xt_geoip/dbip-country-lite.csv.gz; then
   echo -e "\e[31;1;208mERROR:\e[0m Fail to download database. Try to download manually https://download.db-ip.com/free/dbip-country-lite-${YR}-${MON}.csv.gz"
 else
   gunzip /usr/share/xt_geoip/dbip-country-lite.csv.gz
   # ## Generate files.
   /usr/lib/xtables-addons/xt_geoip_build -D /usr/share/xt_geoip/ -S /usr/share/xt_geoip/
   rm /usr/share/xt_geoip/dbip-country-lite.csv
 fi


# ## Exit.
exit 0

# ## END
