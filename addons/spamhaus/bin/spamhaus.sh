#! /bin/bash
#set -x
# * **************************************************************************
# *
# * Creation:           (c) 2004-2022  Cybionet - Ugly Codes Division
# *
# * File:               spamhaus.sh
# * Version:            1.0.0
# *
# * Comment:            Tool to populate Spamhaus list for iptables.
# *
# * Creation: February 25, 2022
# * change:   February 26, 2022
# *
# * **************************************************************************
# * chmod 500 spamhaus.sh
# ****************************************************************************


# ############################################################################################
# ## CUSTOM VARIABLES

# ## Path where is located the custom rules file.
declare -r customPath='/root/running_scripts/iptables'

# ## Enable downloading IPv6 Spamhaus list (UNUSED).
IPV6=0


# ############################################################################################
# ## FUNCTIONS

function checkPackage() {
 APPDEP="${1}"
 if ! dpkg-query -s "${APPDEP}" > /dev/null 2>&1; then
   echo -e "\e[34;1;208mINFORMATION:\e[0m Spamhaus is not configured. Missing package ${APPDEP}."
   exit 0
 fi
}

# ## IPv4
function shIpv4() {
 # ## The DROP list will not include any IP address space under the control of any legitimate network - even if being used by "the spammers from hell".
 # ## DROP will only include netblocks allocated directly by an established Regional Internet Registry (RIR) or National Internet Registry (NIR)
 # ## such as ARIN, RIPE, AFRINIC, APNIC, LACNIC or KRNIC or direct RIR allocations. 
 wget -T3 -q https://www.spamhaus.org/drop/drop.txt -O "${customPath}"/drop.txt || rm -f "${customPath}"/drop.txt
 if [ -f "drop.txt" ]; then
   cat "${customPath}"/drop.txt | grep -v "^;" | awk -F " ; " '{print $1}' > "${customPath}"/spamhaus.ip
   rm "${customPath}"/drop.txt
 fi

 # ## Extension of the DROP list that includes suballocated netblocks controlled by spammers or cyber criminals. 
 wget -T3 -q https://www.spamhaus.org/drop/edrop.txt -O "${customPath}"/edrop.txt || rm -f "${customPath}"/edrop.txt
 if [ -f "edrop.txt" ]; then
   cat "${customPath}"/edrop.txt | grep -v "^;" | awk -F " ; " '{print $1}' >> "${customPath}"/spamhaus.ip
   rm "${customPath}"/edrop.txt
 fi
}

# ## IPv6
function shIpv6() {
 # ## The DROPv6 list includes IPv6 ranges allocated to spammers or cyber criminals.
 # ## DROPv6 will only include IPv6 netblocks allocated directly by an established Regional Internet Registry (RIR) or National Internet Registry (NIR)
 # ## such as ARIN, RIPE, AFRINIC, APNIC, LACNIC or KRNIC or direct RIR allocations. 
 if [ "${IPV6}" -eq 1 ]; then
   wget -T3 -q https://www.spamhaus.org/drop/dropv6.txt -O "${customPath}"/dropv6.txt || rm -f "${customPath}"/dropv6.txt
   if [ -f "dropv6.txt" ]; then
     cat "${customPath}"/dropv6.txt | grep -v "^;" | awk -F " ; " '{print $1}' > "${customPath}"/spamhausv6.ip
   fi
 fi
}


# ############################################################################################
# ## EXECUTION

checkPackage 'ipset'

shIpv4
shIpv6


# ## Exit
exit 0

# ## END
