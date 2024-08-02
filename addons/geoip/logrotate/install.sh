#! /bin/bash
#set -x

cp iptables /etc/logrotate.d/

mkdir -p /root/running_scripts/iptables/logrotate/
cp logrotate/country.sh /root/running_scripts/iptables/logrotate/


# ## Exit.
exit 0

# ## END
