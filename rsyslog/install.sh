#! /bin/bash
#set -x
# ****************************************************************************
# *
# * Author:             (c) 2004-2023  Cybionet - Ugly Codes Division
# *
# * File:               install.sh
# * Version:            1.1
# *
# * Description:        Script to install rsyslog environment for 40-iptables.
# *
# * Creation: December 02, 2013
# * Change:   May 05, 2023
# *
# ****************************************************************************
# * chmod 500 install.sh
# ****************************************************************************

if [ ! -f "/etc/rsyslog.d/20-iptables.conf" ]; then
  cp 20-iptables.conf /etc/rsyslog.d/20-iptables.conf
  systemctl restart rsyslog.service
else
  echo "The file already exist."
fi

touch /var/log/iptables.log
chown syslog:adm /var/log/iptables.log

# ## Exit.
exit 0

# ## END
