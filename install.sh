#! /bin/bash
#set -x
# ****************************************************************************
# *
# * Creation:           (c) 2004-2022  Cybionet - Ugly Codes Division
# *
# * File:               install.sh
# * Version:            1.1.21
# *
# * Comment:            Script to install environment for 40-iptables.
# *
# * Creation: December 02, 2013
# * Change:   February 23, 2022
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
# ## VERIFICATION

# ## Check if the script are running with sudo or under root user.
if [ "${EUID}" -ne 0 ] ; then
  echo -e "\n\e[34m${appHeader}\e[0m\n"
  echo -e "\n\n\n\e[33mCAUTION: This script must be run with sudo or as root.\e[0m"
  exit 0
else
  echo -e "\n\e[34m${appHeader}\e[0m"
  printf '%.s─' $(seq 1 "$(tput cols)")
fi


# #################################################################
# ## EXECUTION

# ## Installation of dependancies.
if ! dpkg-query -s "${fwPersistent}" > /dev/null 2>&1; then
  echo -e "\e[34;1;208mINFORMATION:\e[0m Installing ${fwPersistent} package."
  apt-get install "${fwPersistent}"
fi

# ## Copy IPv4 persistent script.
cp ./bin/40-iptables /usr/share/netfilter-persistent/plugins.d/
chmod 500 /usr/share/netfilter-persistent/plugins.d/40-iptables

# ## Copy IPv6 persistent script.
cp ./bin/60-ip6tables /usr/share/netfilter-persistent/plugins.d/
chmod 500 /usr/share/netfilter-persistent/plugins.d/60-ip6tables

# ## Create a place for rules if they don't exist.
if [ ! -d "${rulesLocation}" ]; then
  mkdir -p "${rulesLocation}"
fi

ln -sf /usr/share/netfilter-persistent/plugins.d/40-iptables "${rulesLocation}"
ln -sf /usr/share/netfilter-persistent/plugins.d/60-ip6tables "${rulesLocation}"

echo -e "\e[38;5;208mWARNING: Please configure the 40-iptables and 60-ip6tables scripts before restarting.\e[0m\n vim /usr/share/netfilter-persistent/plugins.d/40-iptables"

# ## Exit.
exit 0

# ## END
