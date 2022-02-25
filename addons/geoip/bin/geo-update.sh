#! /bin/bash
#set -x
# * **************************************************************************
# * Creation:           (c) 2004-2022  Cybionet - Ugly Codes Division
# *
# * File:               geo-update.sh
# * Version:            0.1.1
# *
# * Comment:            Tool to configure install geoip for iptables.
# *
# * Date: September 07, 2021
# * Modification: February 23, 2022
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

function checkPackage() {
 APPDEP="${1}"
 if ! dpkg-query -s "${APPDEP}" > /dev/null 2>&1; then
   echo -e "\e[34;1;208mINFORMATION:\e[0m It_geoip is not configured. Missing package ${APPDEP}."
   exit 0
 fi
}


# #################################################################
# ## EXECUTION

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
