#! /bin/bash
#set -x
# ****************************************************************************
# *
# * Author:             (c) 2004-2022  Cybionet - Ugly Codes Division
# *
# * File:               install.sh
# * Version:            1.1.25
# *
# * Description:        Script to install environment for 40-iptables.
# *
# * Creation: December 02, 2013
# * Change:   July 14, 2022
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
readonly adminLocation='/root/admin_scripts/services/iptables'


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

# ## Check Ubuntu version.
 release=$(lsb_release -r | awk -F " " '{print $2}')

 if [[ "${release:0:2}" =~ ^(16|18)$ ]]; then
   echo -e "\e[31;1;208mERROR:\e[0m Your version of Ubuntu is too old (Ubuntu ${release}). It will not support Geoip addon. Please use Ubuntu 20.04 and above."
   echo -e "For Ubuntu 16.04 and 18.04, you can check this documentation: https://ultramookie.com/2020/07/geoip-blocking/"
 fi


# #################################################################
# ## FUNCTIONS

function iptablesLog() {
 cp rsyslog/20-iptables.conf /etc/rsyslog.d/20-iptables.conf
 systemctl restart rsyslog.service

 cp logrotate/iptables /etc/logrotate.d/
}

function attTool() {
 cp tools/attgraph.sh "${adminLocation}"
}

function baseDirectory() {
 # ## Create a location for rules if it does not exist.
 if [ ! -d "${rulesLocation}" ]; then
   mkdir -p "${rulesLocation}"
 fi

 # ## Create a location for the admin scripts if it does not exist.
 if [ ! -d "${adminLocation}" ]; then
   mkdir -p "${adminLocation}"
 fi
}


# #################################################################
# ## EXECUTION

# ## Installation of dependancies.
if ! dpkg-query -s "${fwPersistent}" > /dev/null 2>&1; then
  echo -e "\e[34;1;208mINFORMATION:\e[0m Installing ${fwPersistent} package."
  apt-get install "${fwPersistent}"
fi

# ## Create the directories for the rules and admin script if they do not exist.
baseDirectory

# ## Copy IPv4 persistent script.
cp ./bin/40-iptables /usr/share/netfilter-persistent/plugins.d/
chmod 500 /usr/share/netfilter-persistent/plugins.d/40-iptables
ln -sf /usr/share/netfilter-persistent/plugins.d/40-iptables "${rulesLocation}"

# ## Copy IPv4 configuration script.
mkdir /etc/iptables/
cp ./conf/40-iptables.conf /etc/iptables/
chmod 440 /etc/iptables/40-iptables.conf
ln -sf /etc/iptables/40-iptables.conf "${rulesLocation}"

# ## Copy IPv4 empty custom rules file.
cp ./conf/custom.rules "${rulesLocation}"
chmod 440 "${rulesLocation}"/custom.rules

# ## Copy IPv6 persistent script.
cp ./bin/60-ip6tables /usr/share/netfilter-persistent/plugins.d/
chmod 500 /usr/share/netfilter-persistent/plugins.d/60-ip6tables
ln -sf /usr/share/netfilter-persistent/plugins.d/60-ip6tables "${rulesLocation}"

# ## Create separated log for iptables.
iptablesLog

# ## Last message.
echo -e "\e[38;5;208mWARNING: Please configure the 40-iptables scripts before restarting.\e[0m\n vim /etc/40-iptables.conf"


# ## Exit.
exit 0

# ## END
