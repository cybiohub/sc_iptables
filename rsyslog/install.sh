#! /bin/bash
#set -x

if [ ! -f "/etc/rsyslog.d/20-iptables.conf" ]; then
  cp 20-iptables.conf /etc/rsyslog.d/20-iptables.conf
  systemctl restart rsyslog.service
else
  echo "The file already exist."
fi

# ## Exit.
exit 0

# ## END
