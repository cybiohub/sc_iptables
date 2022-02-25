#! /bin/bash
#set -x
# * **************************************************************************
# * Creation:           (c) 2004-2022  Cybionet - Ugly Codes Division
# *
# * File:               install.sh
# * Version:            0.1.0
# *
# * Comment:            Tool to configure install TOR bulk next list for iptables.
# *
# * Date: September 07, 2021
# * Modification: January 21, 2022
# *
# * **************************************************************************
# * chmod 500 install.sh
# ****************************************************************************

echo 'NOT PRODUCTION READY.'
exit 0


# #################################################################
# ## VARIABLES
# ## SANS LE trailingslash
rulesLocation='/root/running_scripts/iptables'


# #################################################################
# ## EXECUTION

# ## Installing the ipset package.
function ipsetIns() {
  apt-get install ipset
}

function ipsetIns() {
 if [ ! -d "${rulesLocation}" ]; then
   mkdir -p "${rulesLocation}"
 fi

wget -t 1 -T 5 "https://check.torproject.org/torbulkexitlist" > "${rulesLocation}/torbulkexit.ip"

ipset list tor-nodes | wc -l
# ## A CORRIGER 0 == GO!!
ipset create tor-nodes iphash

cat torbulkexit.ip | while read TORIP; do ipset -q -A tor-nodes "${TORIP}"; done


# ##
cp ./cron.d/torlistupdate /etc/cron.d/torlistupdate



# #################################################################
# ## CHECK
iptables -N TORDENY

iptables -A TORDENY -m set --match-set tor-nodes src -j LOG --log-prefix "IPTABLES: TOR "
    iptables -A TORDENY -m set --match-set tor-nodes src -j DROP


# ## Exit 0
exit 0

# ## END
