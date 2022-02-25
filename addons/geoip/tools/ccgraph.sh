#! /bin/bash
# * **************************************************************************
# * Creation:           (c) 2004-2022  Cybionet - Ugly Codes Division
# *
# * File:               ccgraph.sh
# * Version:            0.0.2
# *
# * Comment:            Tool to graph number of hits by country in iptables log.
# *
# * Creation: January 31, 2022
# * Change:   February 04, 2022
# *
# * **************************************************************************


#############################################################################################
# ## VARIABLES

# ## get year.
appYear=$(date +%Y)

# ## Application informations.
appHeader="(c) 2004-${appYear}  Cybionet - Ugly Codes Division"
readonly appVersion='0.0.2'


#############################################################################################
# ## FUNCTIONS

# ## Show the version of this app (hidden option).
function version() {
 echo -e "Version: ${appVersion}\n"
}

# ##
function allCCUsed() {
 allcc=$(iptables -S | grep "source-country" | grep "DROP" | awk -F " " '{print $6}' | grep -v 'tcp' | tr '\n' " ")

 echo -e '\n\n========================\n'
  echo -e "Deny Country Code: ${allcc}\n"
}

function logEntryInfo() {
 firstDate=$(cat "/var/log/iptables.log" | head -n1 | awk -F " " '{print $1,$2,$3}')
 lastDate=$(cat "/var/log/iptables.log" | tail -n1 | awk -F " " '{print $1,$2,$3}')
}

function genGraph() {

 # ## Sort and count country code.
 countryCode=$(cat /var/log/iptables.log | grep "Country" | awk -F ' ' '{print $10}' | grep -v ':\|=\|AUTH' | sort | uniq -c)
# cat /var/log/iptables.log | awk -F ':' '{print $5}' | grep -v ':\|=\|AUTH' | sort | uniq -c


 # ## Character used to print bar chart.
 barchr='+'

 # ## current min, max values [from 'ps' output]
 vmin=1
 vmax=$(echo "${countryCode}" | awk 'BEGIN {max=0} {if($1>max) max=$1} END {print max}')

 # ## range of the bar graph
 dmin=1
 dmax=56

 # ## color steps
 cstep1="\033[32m"
 cstep2="\033[33m"
 cstep3="\033[31m"
 cstepc="\033[0m"

 # ## Generate output.
 echo -e "\n\e[34m${appHeader}\e[0m"
printf '%.s─' $(seq 1 "$(tput cols)")
 echo -e "First Entry: ${firstDate}   Last Entry: ${lastDate}\n"

 echo "${countryCode}" | awk --assign dmin="${dmin}" --assign dmax="${dmax}" \
                             --assign vmin="${vmin}" --assign vmax="${vmax}" \
                             --assign cstep1="${cstep1}" --assign cstep2="${cstep2}" --assign cstep3="${cstep3}" --assign cstepc="${cstepc}"\
                             --assign barchr="${barchr}" \
                             'BEGIN {printf("%15s %7s %2s%54s\n","Country Code","Count","|<", "Hit >|")}
                              {
                                x=int(dmin+($1-vmin)*(dmax-dmin)/(vmax-vmin));
                                printf("%15s %7s ",$2,$1);
                                for(i=1;i<=x;i++)
                                {
                                    if (i >= 1 && i <= int(dmax/3))
                                      {printf(cstep1 barchr cstepc);}
                                    else if (i > int(dmax/3) && i <= int(2*dmax/3))
                                      {printf(cstep2 barchr cstepc);}
                                    else
                                      {printf(cstep3 barchr cstepc);}
                                };
                                print ""
                              }'

 printf '%.s─' $(seq 1 "$(tput cols)")
}


#############################################################################################
# ## EXECUTION
clear
logEntryInfo
genGraph

# ## Exit.
exit 0

# ## END
