#! /bin/bash
#set -x
# ****************************************************************************
# *
# * Author:             (c) 2004-2022  Cybionet - Ugly Codes Division
# *
# * File:               redlistnodes.sh
# * Version:            1.0.0
# *
# * Comment:            Script to manually execute redlist nodes rules.
# *                     Use 40-iptables instead of this script.
# *
# * Creation: February 26, 2022
# * Change:   May 18, 2022
# *
# ****************************************************************************
# *
# * Dependancy: 
# *   ipset
# *
# * **************************************************************************
# ## REDLIST.


# ############################################################################################
# ## VARIABLES

# ## Force configuration of the script.
# ## Value: enabled (true), disabled (false).
declare -r isConfigured='false'

# ## Path where is located the custom rules file.
declare -r customPath='/root/running_scripts/iptables'


# ############################################################################################
# ## EXECUTION

# ## Check if the script is configured.
if [ "${isConfigured}" == 'false' ] ; then
  echo -n -e '\e[38;5;208mWARNING: Customize the settings to match your environment. Then set the "isConfigured" variable to "true".\n\e[0m'
  exit 0
fi

# ## Check if ipset package is installed.
if ! dpkg-query -s 'ipset' > /dev/null 2>&1; then
  echo -e "\e[31;1;208mERROR:\e[0m REDLIST extra protection security skipped. Missing dependancy (ipset)."      
  exit 0
  # ## Else, populate the Redlist node.
else

  redList=$(ipset list redlist-nodes | wc -l)

  if [ "${redList}" -le 2 ]; then
    ipset create redlist-nodes iphash
  fi

  # ## Check if the custom path exist. If it does not exist, create it.
  if [ ! -d "${customPath}" ]; then
    mkdir -p "${customPath}"
  fi

  # ## Check if the redlist ip list file exist.
  if [ ! -f "${customPath}/redlist.ip" ]; then
    touch "${customPath}/redlist.ip"
  fi

  while IFS= read -r REDIP; do echo "${REDIP%?}";
    ipset -q -A redlist-nodes "${REDIP}"
  done < "${customPath}"/redlist.ip

  iptables -N REDLIST
  iptables -A INPUT -j REDLIST

  iptables -A REDLIST -m set --match-set redlist-nodes src -j LOG --log-prefix "IPTABLES: REDLIST: "
  iptables -A REDLIST -m set --match-set redlist-nodes src -j DROP

  # ## Verification.
  ipset -t list redlist-nodes
fi


# ## Exit.
exit 0

# ## END
