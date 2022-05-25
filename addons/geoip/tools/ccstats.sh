#! /bin/bash
#set -x
# * **************************************************************************
# *
# * Author:             (c) 2004-2022  Cybionet - Ugly Codes Division
# *
# * File:               ccstats.sh
# * Version:            0.0.2
# *
# * Description:        Tool to Displays statistics for a specific country in the iptables log.
# *
# * Creation: January 31, 2022
# * Change:   February 23, 2022
# *
# * **************************************************************************


#############################################################################################
# ## VARIABLES

# ## Log file location.
log='/var/log/iptables.log'

# ##
country="${1^^}"

# ## get year.
appYear=$(date +%Y)

# ## Application informations.
appHeader="(c) 2004-${appYear}  Cybionet - Ugly Codes Division"
readonly appVersion='0.0.2'


#############################################################################################
# ## FUNCTION

# ## Show the version of this app (hidden option).
function version() {
 echo -e "Version: ${appVersion}\n"
}

function logEntryInfo() {
 firstDate=$(cat "${log}" | head -n1 | awk -F " " '{print $1,$2,$3}')
 lastDate=$(cat "${log}" | tail -n1 | awk -F " " '{print $1,$2,$3}')
}


#############################################################################################
# ## EXECUTION

clear
logEntryInfo

# ## Generate output.
echo -e "\n\e[34m${appHeader}\e[0m"
printf '%.s─' $(seq 1 "$(tput cols)")
echo -e "First Entry: ${firstDate}   Last Entry: ${lastDate}\n"

if [ -z "${country}" ]; then
  echo "Country Code needed"
  exit 0
fi

echo -e "Country:\t ${country}"
ccCount=$(cat /var/log/iptables.log | grep "${country}" | awk -F ' ' '{print $10}' | grep -v ':\|=\|AUTH' | wc -l)

echo -e "Connexion:\t ${ccCount}"
ipCount=$(cat /var/log/iptables.log | grep "${country}" | awk -F " " '{print $14}' | sort | uniq | wc -l)

echo -e "IP Count:\t ${ipCount}"
echo "------------------------------------"
cat /var/log/iptables.log | grep "${country}" | awk -F " " '{print $14}' | sort | uniq | awk -F "=" '{print $2}'
echo -e "------------------------------------\n"


# ## Exit.
exit 0

# ## END
