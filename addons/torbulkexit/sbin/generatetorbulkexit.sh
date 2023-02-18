#! /bin/bash
#set -x
# * **************************************************************************
# *
# * Author:             (c) 2004-2023  Cybionet - Ugly Codes Division
# *
# * File:               generatetorbulkexit.sh
# * Version:            0.1.2
# *
# * Description:        Tool to populate Tor bulk exit nodes list.
# *
# * Creation: April 15, 2022
# * Change:   February 17, 2023
# *
# * **************************************************************************
# * chmod 500 generatetorbulkexit.sh
# *
# * vim /etc/cron.d/torlistupdate 
# *   30 19 * * * /usr/sbin/generatetorbulkexit.sh
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

# ## Download the new list of Tor bulk exit nodes.
wget  -t"${wgetRetry}" -T"${wgetTimeout}" -q -O - https://check.torproject.org/torbulkexitlist > "${customPath}/torbulkexit.ip"

logger -t torlist -p user.info "Download complete."

# ## Populating the ipset list.
if [[ -f "${customPath}/torbulkexit.ip" && -n "${customPath}" ]]; then

  /sbin/ipset create new-tor-nodes iphash

  while IFS= read -r TORIP; do echo "${TORIP%?}";
    /sbin/ipset -q -A new-tor-nodes "${TORIP}"
  done < "${customPath}"/torbulkexit.ip

  /sbin/ipset swap new-tor-nodes tor-nodes
  /sbin/ipset destroy new-tor-nodes

  logger -t torlist -p user.info "Finished to populated list."
else
  echo -n -e "\e[38;5;208mWARNING:\e[0m The list of IP addresses is empty or does not exist."
  logger -t torlist -p user.warn "The list of IP addresses is empty or does not exist."
fi


# ## Exit.
exit 0

# ## END
