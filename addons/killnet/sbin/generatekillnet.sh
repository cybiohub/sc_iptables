#! /bin/bash
#set -x
# * **************************************************************************
# *
# * Author:             (c) 2004-2023  Cybionet - Ugly Codes Division
# *
# * File:               generatekillnet.sh
# * Version:            0.1.1
# *
# * Description:        Tool to populate KillNet DDoS list.
# *
# * Creation: February 17, 2023
# * Change:   
# *
# * **************************************************************************
# * chmod 500 generatekillnet.sh
# *
# * vim /etc/cron.d/killnetupdate 
# *   30 19 * * * /usr/sbin/generatekillnet.sh
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

# ## Download KillNet DDoS list.
wget -t"${wgetRetry}" -T"${wgetTimeout}" -q -O - https://raw.githubusercontent.com/securityscorecard/SSC-Threat-Intel-IoCs/master/KillNet-DDoS-Blocklist/proxylist.txt > "${customPath}/killnet.ip"

logger -t killnet -p user.info "Download complete."

# ## Populating the ipset list.
if [[ -f "${customPath}/killnet.ip" && -n "${customPath}" ]]; then

  /sbin/ipset create new-killnet-nodes iphash

  # ## Populate KNIP chain.
  cat "${customPath}"/killnet.ip | awk -F ":" '{print $1}' | while read -r KNIP;do ipset -q -A new-killnet-nodes "${KNIP}"; done

  /sbin/ipset swap new-killnet-nodes killnet-nodes
  /sbin/ipset destroy new-killnet-nodes

  logger -t killnet -p user.info "Finished to populated list."
else
  echo -n -e "\e[38;5;208mWARNING:\e[0m The list of IP addresses is empty or does not exist."
  logger -t killnet -p user.warn "The list of IP addresses is empty or does not exist."
fi


# ## Exit.
exit 0

# ## END
