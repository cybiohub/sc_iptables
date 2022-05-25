#! /bin/bash
#set -x
# ****************************************************************************
# *
# * Author:		(c) 2004-2022  Cybionet - Ugly Codes Division
# *
# * File:               tornodes.sh
# * Version:            1.0.0
# *
# * Comment:            Script to manually execute tor exit nodes rules.
# *			Use 40-iptables instead of this script.
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
# ## TOR EXIT NODES.


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
  echo -e "\e[31;1;208mERROR:\e[0m TORDENY extra protection security skipped. Missing dependancy (ipset)."	 
  exit 0
else
  torList=$(ipset list tor-nodes | wc -l)

  if [ "${torList}" -le 2 ]; then
    ipset create tor-nodes iphash
  fi

  # ## Check if the custom path exist. If it does not exist, create it.
  if [ ! -d "${customPath}" ]; then
    mkdir -p "${customPath}"
  fi

  # ## Check if the shodan ip list file exist.
  if [ ! -f "${customPath}"/torbulkexit.ip ]; then
    touch "${customPath}"/torbulkexit.ip
  fi

  cat "${customPath}"/torbulkexit.ip | while read TORIP; do
    ipset -q -A tor-nodes "${TORIP}"
  done

  iptables -N TORDENY
  iptables -A INPUT -j TORDENY

  iptables -A TORDENY -m set --match-set tor-nodes src -j LOG --log-prefix "IPTABLES: TOR "
  iptables -A TORDENY -m set --match-set tor-nodes src -j DROP

  # ## Verification.
  ipset -t list tor-nodes
fi


# ## Exit.
exit 0

# ## END
