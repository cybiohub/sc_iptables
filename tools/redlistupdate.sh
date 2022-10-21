#! /bin/bash
#set -x
# * **************************************************************************
# *
# * Author:             (c) 2004-2022  Cybionet - Ugly Codes Division
# *
# * File:               redlistupdate.sh
# * Version:            0.1.0
# *
# * Description:        Tool to manually populate Red List.
# *
# * Creation: October 18, 2022
# * Change:   October 18, 2022
# *
# * **************************************************************************
# * chmod 500 redlistupdate.sh
# *
# *
# *  ipset list redlist-nodes
# *
# * **************************************************************************


# ############################################################################################
# ## VARIABLES
  
# ## Path where is located the custom rules file.
declare -r customPath='/root/running_scripts/iptables'

declare -r appPath="$(which ipset)"


# ############################################################################################
# ## EXECUTION

# ## Populating the ipset list.
if [[ -f "${customPath}/redlist.ip" && -n "${customPath}/redlist.ip" ]]; then

  "${appPath}" create new-redlist-nodes iphash

  while IFS= read -r REDIP; do echo "${TORIP%?}";
    "${appPath}" -q -A new-redlist-nodes "${REDIP}"
  done < "${customPath}"/redlist.ip

  "${appPath}" swap new-redlist-nodes redlist-nodes
  "${appPath}" destroy new-redlist-nodes
else
  echo -n -e "\e[38;5;208mWARNING:\e[0m The list of IP addresses is empty or does not exist."
fi

count="$(${appPath} list redlist-nodes | tail -n 6 | wc -l)"

echo -e "\nThe list contain ${count} entries"


# ## Exit.
exit 0

# ## END
