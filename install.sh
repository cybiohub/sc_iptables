#! /bin/bash
#set -x
# ****************************************************************************
# *
# * Creation:           (c) 2004-2022  Cybionet - Ugly Codes Division
# *
# * File:               40-iptables
# * Version:            1.1.21
# *
# * Comment:            Script to customize the IPv4 rules of a dynamic firewall interface.
# *
# * Date:   December 02, 2013
# * Change: February 23, 2022
# *
# ****************************************************************************
# * chmod 500 install.sh
# ****************************************************************************


# #################################################################
# ## CUSTOM VARIABLES

# ## Two possible choices:netfilter-persistent or iptables-persistent.
readonly fwPersistent='iptables-persistent'

# ## Do not put the trailing slash.
readonly rulesLocation='/root/running_scripts/iptables'


# #################################################################
# ## VARIABLES

# ## Actual date.
actualYear=$(date +"%Y")
declare -r actualYear

# ## Title header.
appHeader="(c) 2004-${actualYear}  Cybionet - Installation Wizard"
declare -r appHeader


#############################################################################################
# ## FUNCTION


#############################################################################################
# ## VERIFICATION

# ## Check if the script are running with sudo or under root user.
if [ "${EUID}" -ne 0 ] ; then
  echo -e "\n\e[34m${appHeader}\e[0m\n"
  echo -e "\n\n\n\e[33mCAUTION: This script must be run with sudo or as root.\e[0m"
  exit 0
else
  echo -e "\n\e[34m${appHeader}\e[0m"
  printf '%.s─' $(seq 1 "$(tput cols)")

 echo -n -e '\e[38;5;208mWARNING: SORRY THE WIZARD IS NOT READY FOR PRODUCTION.\n\e[0m'
 exit 0
fi


# #################################################################
# ## EXECUTION

# ## Installation of dependancies.
if ! dpkg-query -s "${fwPersistent}" > /dev/null 2>&1; then
  echo -e "\e[33;1;208mWARNING:\e[0m SHODAN extra protection security skipped. Missing dependancy (ipset)."
  apt-get install "${fwPersistent}"
fi

# ## Copy persistent script.
cp ./bin/40-iptables /usr/share/netfilter-persistent/plugins.d/
chmod 500 /usr/share/netfilter-persistent/plugins.d/40-iptables

# ## Create a place for rules if they don't exist.
if [ ! -d "${rulesLocation}" ]; then
  mkdir -p "${rulesLocation}"
fi

ln -sf /usr/share/netfilter-persistent/plugins.d/40-iptables "${rulesLocation}"

echo -e "\e[38;5;208mWARNING: Please configure the iptables-40 script before restarting.\e[0m\n vim /usr/share/netfilter-persistent/plugins.d/40-iptables"

# ## Exit.
exit 0

# ## END
