#! /bin/bash
#set -x
# ****************************************************************************
# *
# * Author:             (c) 2004-2023  Cybionet - Ugly Codes Division
# *
# * File:               spamhausnodes.sh
# * Version:            1.0.0
# *
# * Description:        Script to manually execute spamhaus rules.
# *                     Use 40-iptables instead of this script.
# *
# * Creation: February 26, 2022
# * Change:   January 26, 2023
# *
# ****************************************************************************
# *
# * Dependancy: 
# *   ipset
# *
# * **************************************************************************
# ## SPAMHAUS.


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
  echo -e "\e[31;1;208mERROR:\e[0m SPAMHAUS extra protection security skipped. Missing dependancy (ipset)."
  exit 0
# ## Else, populate the Spamhaus node.
else
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

  iptables -N SPAMHAUSDENY
  iptables -A INPUT -j SPAMHAUSDENY

  iptables -A SPAMHAUSDENY -m set --match-set spamhaus-nodes src -j LOG --log-prefix "IPTABLES: SPAMHAUS: "
  iptables -A SPAMHAUSDENY -m set --match-set spamhaus-nodes src -j DROP

  # ## Verification.
  ipset -t list spamhaus-nodes
fi


# ## Exit.
exit 0

# ## END
