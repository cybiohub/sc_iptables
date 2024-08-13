#! /bin/bash
#set -x
# * **************************************************************************
# *
# * Author:             (c) 2004-2024  Cybionet - Ugly Codes Division
# *
# * File:               generateshodan.sh
# * Version:            0.1.1
# *
# * Description:        Tool to populate KillNet DDoS list.
# *
# * Creation: August 05, 2024
# * Change:
# *
# * **************************************************************************
# * chmod 500 generateshodan.sh
# *
# * **************************************************************************


# ############################################################################################
# ## VARIABLES

# ## Path where is located the custom rules file.
declare -r customPath='/root/running_scripts/iptables'

# ## Download parameters.
wgetRetry=3
wgetTimeout=3


# ############################################################################################
# ## EXECUTION

# ## Populating the ipset list.
if [[ -f "${customPath}/shodan.ip" && -n "${customPath}" ]]; then

  /sbin/ipset create new-shodan-nodes iphash

  # ## Populate chain.
  cat "${customPath}"/shodan.ip | awk -F ":" '{print $1}' | while read -r SHODANIP;do ipset -q -A new-shodan-nodes "${SHODANIP}"; done


  /sbin/ipset swap new-shodan-nodes shodan-nodes
  /sbin/ipset destroy new-shodan-nodes

  logger -t shodan -p user.info "Finished to populated list."
else
  echo -n -e "\e[38;5;208mWARNING:\e[0m The list of IP addresses is empty or does not exist."
  logger -t shodan -p user.warn "The list of IP addresses is empty or does not exist."
fi


# ## Exit.
exit 0

# ## END
