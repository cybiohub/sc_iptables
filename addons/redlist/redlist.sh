#! /bin/bash
#set -x
# * **************************************************************************
# *
# * Author:             (c) 2004-2025  Cybionet - Ugly Codes Division
# *
# * File:               redlist.sh
# * Version:            0.2.1
# *
# * Description:        Tool to Add/Remove/Show IP Address in redlist-node ipset for iptables.
# *
# * Creation: March 29, 2022
# * Change:   April 18, 2025
# *
# * **************************************************************************
# * chmod 500 redlist.sh
# ****************************************************************************


# #############################################################################
# ## CUSTOM VARIABLES

customPath='/root/running_scripts/iptables/redlist.ip'


# #############################################################################
# ## VARIABLES

# ## Retrieval of date and year.
appYear=$(date +%Y)

# ## Ipset application.
declare -r appPath="$(which ipset)"

# ## Application informations.
appHeader="(c) 2004-${appYear}  Cybionet - Ugly Codes Division"
readonly appVersion='0.2.1'


# #############################################################################
# ## VERIFICATION

# ## Check if the script are running with sudo or under root user.
if [ "${EUID}" -ne 0 ] ; then
 echo -e "\n\e[34m${appHeader}\e[0m\n"
 echo -e "\n\n\n\e[33mCAUTION: This script must be run with sudo or as root.\e[0m"
 exit 0
fi

# ## Check if the redlist ip list file exist.
if [ ! -f "${customPath}" ]; then
 echo -e "\n\n\n\e[33mCAUTION: The file does not exist.\e[0m"
 exit 0
fi


# #############################################################################
# ## FUNCTIONS

function header(){
 echo -e "\n\e[34m${appHeader}\e[0m"
 printf '%.s─' $(seq 1 "$(tput cols)")
}

# ## Add an IP address to the Redlist.
function addIp {
 read -p "IP Address: " ip;
 checkIp "${ip}" "${FUNCNAME}"

 "${appPath}" --add redlist-nodes "${ip}"
}

# ## Delete an IP address to the Redlist.
function delIp() {
 read -p "IP Address: " ip;
 checkIp "${ip}" "${FUNCNAME}"

 "${appPath}" --del redlist-nodes "${ip}"
}

# ##
function populate() {
 while IFS= read -r REDIP; do echo "${REDIP%?}";
   "${appPath}" -q -A redlist-nodes "${REDIP}"
 done < "${customPath}"
}

# ##
function checkIp() {
 local ipv4="${1}"
 local retrycheck="${2}"

 if expr "${ipv4}" : '[1-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
   for i in 1 2 3 4; do
     if [ $(echo "${ipv4}" | cut -d. -f${i}) -gt 255 ]; then
       echo -e "Not a valid ip address (${ipv4})."
       ${retrycheck}
     fi
   done
 else
   echo -e "Not a valid ip address (${ipv4:-Empty})."
   ${retrycheck}
 fi
}

# ## Displays all IP addresses in the list.
function showList() {
 "${appPath}" list redlist-nodes | tail -n +9 | sort -n
}

# ## Displays list information.
function infoList() {
 "${appPath}" list redlist-nodes | head -n 7
}

# ## Makes a backup of the active list.
function backupList() {
 read -p "File name (redlist.bak): " bak;
 "${appPath}" list redlist-nodes > "${bck:-redlist.bak}"
 #bak=${bak:-redlist.bak}
 #"${appPath}" list redlist-nodes > "${bak}"
}

# ## Show the version of this app (ready to use with Ansible or Zabbix).
function version() {
 echo -e "${appVersion}"
}


# #############################################################################
# ## EXECUTION

# ## MENU

case "${1}" in
  -add|add)
        header
        addIp
  ;;
  -del|remove)
        header
        delIp
  ;;
  -pop|populate)
        header
        populate
  ;;
  -back|backup)
        header
        backupList
  ;;
  -list|list)
        header
        showList
  ;;
  -info|info)
        header
        infoList
  ;;
  -ver|version)
        version
  ;;
  *)
  echo -e "\n\n  Usage: ${0##*/} [options]\n"
  echo -e '\n  General options:
    -add,  [add]\t\t# Add an IP address to the list.
    -del,  [remove]\t\t# Remove an IP address from the list.
    -pop,  [populate]\t\t# Bulk add IP addresses by file.
    -back, [backup]\t\t# Make a backup of the loaded list.
    -list, [list]\t\t# Show the list of all IP in the list.
    -info, [info]\t\t# Show informations of this list [IP or NETWORK].
    -ver,  [version]\t\t# Show the program version.\n'
  ;;
esac


# ## Exit.
exit 0

# ## END
