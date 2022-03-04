#! /bin/bash
#set -x

cp 20-iptables.conf /etc/rsyslog.d/20-iptables.conf

systemctl restart rsyslog.service

# ## Exit.
exit 0

# ## END
