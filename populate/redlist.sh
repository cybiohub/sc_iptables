#! /bin/bash
#set -x
# * **************************************************************************
# *
# * Author:             (c) 2004-2022  Cybionet - Ugly Codes Division
# *
# * File:               redlist.sh
# * Version:            0.1.0
# *
# * Description:        Tool to Add/Remove IP Address in redlist-node ipset for iptables.
# *
# * Creation: March 29, 2022
# * Change:   
# *
# * **************************************************************************
# * chmod 500 redlist.sh
# ****************************************************************************


# #################################################################
# ## CUSTOM VARIABLES

customPath='/root/running_scripts/iptables/redlist.ip'


#############################################################################################
# ## VARIABLES

# ## Retrieval of date and year
appYear=$(date +%Y)

# ## Application informations.
appHeader="(c) 2004-${appYear}  Cybionet - Ugly Codes Division"
appVersion='0.1.0'


#############################################################################################
# ## VERIFICATION

# ## Check if the script are running under root user.
if [ "${EUID}" -ne '0' ] ; then
 echo -e "\n\e[34m${appHeader}\e[0m\n"
 echo -e "\n\n\n\e[33mCAUTION: This script must be run as root.\e[0m"
 exit 0
else
 echo -e "\n\e[34m${appHeader}\e[0m"
 printf '%.s─' $(seq 1 "$(tput cols)")
fi

# ## Check if the redlist ip list file exist.
if [ ! -f "${customPath}" ]; then
 echo -e "\n\n\n\e[33mCAUTION: The file does not exist.\e[0m"
 exit 0
fi


# #################################################################
# ## FUNCTIONS

# ## Add an IP address to the Redlist. 
function addIp {
 read -p "IP Address: " ip;
 checkIp "${ip}" "${FUNCNAME}"

 ipset --add redlist-nodes "${ip}"
}

# ## Delete an IP address to the Redlist. 
function delIp() {
 read -p "IP Address: " ip;
 checkIp "${ip}" "${FUNCNAME}"

 ipset --del redlist-nodes "${ip}"
}

# ##
function populate() {
 while IFS= read -r REDIP; do echo "${REDIP%?}";
   ipset -q -A redlist-nodes "${REDIP}"
 done < "${customPath}"
}

# ##
function checkIp() {
 local ipv4="${1}"
 local retrycheck="${2}"

 if expr "${ipv4}" : '[1-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
   for i in 1 2 3 4; do
     if [ $(echo "${ipv4}" | cut -d. -f$i) -gt 255 ]; then
       echo -e "Not a valid ip address (${ipv4})."
       $retrycheck
     fi
   done
  # echo "success (${ipv4})"
 else
   echo -e "Not a valid ip address (${ipv4:-Empty})."
   $retrycheck
 fi
}

# ##
function showList() {
 ipset list redlist-nodes
}

# ##
function backupList() {
 read -p "File name (redlist.bak): " bak;
 ipset list redlist-nodes > "${bck:-redlist.bak}"
}

# ## Show the version of this app (hidden option).
function version() {
 echo -e "Version: ${appVersion}\n"
}


# #################################################################
# ## EXECUTION

# ## MENU

case "${1}" in
  add)
        addIp
  ;;
  del)
        delIp
  ;;
  populate)
        populate
  ;;
  backup)
        backupList
  ;;
  showlist)
       showList
  ;;
  version)
        version
  ;;
  *)
  echo 'Options: add |  del | populate | showlist | backup'
  ;;
esac


# ## Exit.    
exit 0

# ## END
