#! /bin/bash
#set -x
# ****************************************************************************
# *
# * Author:             (c) 2004-2022  Cybionet - Ugly Codes Division
# *
# * File:               shodannodes.sh
# * Version:            1.0.0
# *
# * Comment:            Script to manually execute shodan nodes rules.
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
# ## SHODAN.


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
  echo -e "\e[31;1;208mERROR:\e[0m SHODAN extra protection security skipped. Missing dependancy (ipset)."
  exit 0
# ## Else, populate the Redlist node.
else
  shodanList=$(ipset list shodan-nodes | wc -l)

  if [ "${shodanList}" -le 2 ]; then
    ipset create shodan-nodes iphash
  fi

  # ## Check if the custom path exist. If it does not exist, create it.
  if [ ! -d "${customPath}" ]; then
    mkdir -p "${customPath}"
  fi

  # ## Check if the shodan ip list file exist.
  if [ ! -f "${customPath}"/shodan.ip ]; then
    touch "${customPath}"/shodan.ip
  fi

  cat "${customPath}"/shodan.ip | while read SHODANIP; do
    ipset -q -A shodan-nodes "${SHODANIP}"
  done

  iptables -N SHODAN
  iptables -A INPUT -j SHODAN

  iptables -A SHODAN -m set --match-set shodan-nodes src -j LOG --log-prefix "IPTABLES: SHODAN INPUT "
  iptables -A SHODAN -m set --match-set shodan-nodes src -j DROP

  # ## Verification.
  ipset -t list shodan-nodes
fi


# ## Exit.
exit 0

# ## END
