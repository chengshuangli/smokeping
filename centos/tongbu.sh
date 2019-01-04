#!/bin/bash



Copyfile()
    {
        local file=$1
        local port=$2
        local user=$3
        local host=$4
        local filepash=$5
        scp -P $port $file  $user@$host:$filepash
    }
    
restartsmk()
    {
        local port=$1
        local user=$2
        local host=$3
        ssh -p $port  $user@$host "/root/restart.sh"
    }

    #Copyfile 22 Targets ubuntu host /etc/smokeping/config.d
    #restartsmk 22 ubuntu host

    for i in `cat smk.csv | egrep -v '^#|^$'`
        do
            echo $i
            {
            if echo $i | egrep -q -i 'al|google|uni'
                then
                    echo $i is alin
                    user=root
                elif echo $i | grep -q -i  tencent
                    then
                    echo $i is qq
                    user=ubuntu
                else
                    user=ubuntu
            fi
             host=$(echo $i | awk -F, '{print $1}')
             Copyfile config.dist 22 $user  $host /usr/local/smokeping/etc/
             Copyfile restart.sh  22 $user  $host /root/
             Copyfile httpd.conf  22 $user  $host /etc/httpd/conf/
             restartsmk 22 $user $host
             }&
        done

