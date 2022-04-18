#! /bin/bash
#set -x
# * **************************************************************************
# *
# * Author:             (c) 2004-2022  Cybionet - Ugly Codes Division
# *
# * File:               generatetorbulkexit.sh
# * Version:            0.1.0
# *
# * Description:        Tool to populate Tor bulk exit nodes list.
# *
# * Creation: April 15, 2022
# * Change:   April 17, 2022
# *
# * **************************************************************************
# * chmod 500 generatetorbulkexit.sh
# *
# * vim /etc/cron.d/torlistupdate 
# *   30 19 * * * /root/running_scripts/iptables/generatetorbulkexit.sh
# *
# * **************************************************************************


# ############################################################################################
# ## VARIABLES

# ## Path where is located the custom rules file.
declare -r customPath='/root/running_scripts/iptables'


# ############################################################################################
# ## EXECUTION

# ## Download the new list of Tor bulk exit nodes.
wget -q -O - https://check.torproject.org/torbulkexitlist > "${customPath}/torbulkexit.ip"
logger -t spamhaus -p user.info "Download complete."

# ## Populating the ipset list.
if [[ -f "${customPath}/torbulkexit.ip" && -n "${customPath}/torbulkexit.ip" ]]; then

  ipset create new-tor-nodes iphash

  while IFS= read -r TORIP; do echo "${TORIP%?}";
    ipset -q -A new-tor-nodes "${TORIP}"
  done < "${customPath}"/torbulkexit.ip

  ipset swap new-tor-nodes tor-nodes
  ipset destroy new-tor-nodes

  logger -t torlist -p user.info "Finished to populated list."
else
  echo -n -e "\e[38;5;208mWARNING:\e[0m The list of IP addresses is empty or does not exist."
  logger -t torlist -p user.warn "The list of IP addresses is empty or does not exist."
fi

# ## Exit.
exit 0

# ## END
