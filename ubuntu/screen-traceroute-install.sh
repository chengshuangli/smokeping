#!/bin/bash



for i in `cat  smk.csv |egrep -v '^#|^$'`
    do
        {
        echo $i
        name=$(echo $i | awk -F, '{print $2}')
        ip=$(echo $i | awk -F, '{print $1}')
        if echo $i | egrep -q -i 'al|google'
            then
                ssh -p22 root@$ip "apt-get install screen traceroute -y "
            else
                ssh -p22 ubuntu@$ip "sudo apt-get install screen traceroute -y"
        fi
        }&
    done
