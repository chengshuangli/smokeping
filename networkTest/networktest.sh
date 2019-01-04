#!/bin/bash



sshfile()
    {
        local file=$1
        local port=$2
        local user=$3
        local host=$4

        scp -r -P $port $file  $user@$host:~/
#        ssh -p $port -r  $user@$host "sudo iptables-restore < ~/$file"
    }
    

    #Copyfile 22 Targets ubuntu host /etc/smokeping/config.d
    #restartsmk 22 ubuntu host

    for i in `cat smk.csv | egrep -v '^#|^$'`
        do
            echo $i
            {
            if echo $i | egrep -q -i 'al|google|unic'
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
             #sshfile iptables 22 $user  $host
             sshfile networkTest 22 $user  $host
#             restartsmk 22 $user $host
             }&
        done

