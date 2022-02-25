#! /bin/bash
#set -x

date=$(date +'%Y%d%m-%H%M%S')

result=$(cat /var/log/iptables.log | awk -F ' ' '{print $10}' | grep -v ':\|=\|AUTH' | sort | uniq -c)

echo "${result}" > /root/running_scripts/iptables/logrotate/country-${date}

# ## Exit.

exit 0
# ## END
