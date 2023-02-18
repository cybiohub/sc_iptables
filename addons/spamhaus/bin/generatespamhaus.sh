#! /bin/bash
#set -x
# * **************************************************************************
# *
# * Author:             (c) 2004-2023  Cybionet - Ugly Codes Division
# *
# * File:               generatespamhaus.sh
# * Version:            1.1.3
# *
# * Description:        Tool to populate Spamhaus list for iptables.
# *
# * Creation: February 25, 2022
# * Change:   January 26, 2023
# *
# * **************************************************************************
# *
# * chmod 500 generatespamhaus.sh
# *
# * vim /etc/cron.d/spamhausupdate
# *   30 19 * * * root /usr/sbin/generatespamhaus.sh
# *
# ****************************************************************************


# ############################################################################################
# ## CUSTOM VARIABLES

# ## Path where is located the custom rules file.
declare -r customPath='/root/running_scripts/iptables'

# ## Enable downloading IPv6 Spamhaus list (UNUSED).
IPV6=0

# ## Ipset location.
appIpSet="/sbin/ipset"
#appIpSet="$(which ipset)"


# ############################################################################################
# ## FUNCTIONS

# ## Check if ipset package is installed.
function checkPackage() {
 if ! dpkg-query -s ipset > /dev/null 2>&1; then
   echo -e "\e[34;1;208mINFORMATION:\e[0m Dependencies are missing for Spamhaus. Missing package 'ipset'."
   exit 0
 fi
}

# ## IPv4
function shIpv4() {
 # ## The DROP list will not include any IP address space under the control of any legitimate network - even if being used by "the spammers from hell".
 # ## DROP will only include netblocks allocated directly by an established Regional Internet Registry (RIR) or National Internet Registry (NIR)
 # ## such as ARIN, RIPE, AFRINIC, APNIC, LACNIC or KRNIC or direct RIR allocations.
 wget -T3 -q https://www.spamhaus.org/drop/drop.txt -O "${customPath}"/drop.txt || rm -f "${customPath}"/drop.txt
 if [ -f "${customPath}/drop.txt" ]; then
   grep -v "^;" "${customPath}/drop.txt" | awk -F " ; " '{print $1}' > "${customPath}"/spamhaus.ip
   rm "${customPath}"/drop.txt
 fi

 # ## Extension of the DROP list that includes suballocated netblocks controlled by spammers or cyber criminals.
 wget -T3 -q https://www.spamhaus.org/drop/edrop.txt -O "${customPath}"/edrop.txt || rm -f "${customPath}"/edrop.txt
 if [ -f "${customPath}/edrop.txt" ]; then
   grep -v "^;" "${customPath}/edrop.txt" | awk -F " ; " '{print $1}' >> "${customPath}"/spamhaus.ip
   rm "${customPath}"/edrop.txt
 fi

 logger -t spamhaus -p user.info "Download complete."
}

# ## IPv6
function shIpv6() {
 # ## The DROPv6 list includes IPv6 ranges allocated to spammers or cyber criminals.
 # ## DROPv6 will only include IPv6 netblocks allocated directly by an established Regional Internet Registry (RIR) or National Internet Registry (NIR)
 # ## such as ARIN, RIPE, AFRINIC, APNIC, LACNIC or KRNIC or direct RIR allocations.
 if [ "${IPV6}" -eq 1 ]; then
   wget -T3 -q https://www.spamhaus.org/drop/dropv6.txt -O "${customPath}"/dropv6.txt || rm -f "${customPath}"/dropv6.txt
   if [ -f "dropv6.txt" ]; then
     grep -v "^;" "${customPath}/dropv6.txt" | awk -F " ; " '{print $1}' > "${customPath}"/spamhausv6.ip
   fi
 fi
}

# ## Populating the ipset list.
function popIpset() {
 # ## Populating the ipset list.

 if [[ -f "${customPath}/spamhaus.ip" && -n "${customPath}" ]]; then

   ${appIpSet} create new-spamhaus-nodes nethash

   while IFS= read -r SHIP; do echo "${SHIP%?}";
     "${appIpSet}" -q -A new-spamhaus-nodes "${SHIP}"
   done < "${customPath}/spamhaus.ip"

   "${appIpSet}" swap new-spamhaus-nodes spamhaus-nodes
   "${appIpSet}" destroy new-spamhaus-nodes

   logger -t spamhaus -p user.info "Finished to populated list."
 else
   echo -n -e "\e[38;5;208mWARNING:\e[0m The list of IP addresses is empty or does not exist."
   logger -t spamhaus -p user.warn "The list of IP addresses is empty or does not exist."
 fi
}


# ############################################################################################
# ## EXECUTION

checkPackage

shIpv4
shIpv6
popIpset


# ## Exit
exit 0

# ## END
