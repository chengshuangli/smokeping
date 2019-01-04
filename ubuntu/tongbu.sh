#!/bin/bash



Copyfile()
    {
        local file=$1
        local port=$2
        local user=$3
        local host=$4
        local filepash=$5

        scp -P $port $file  $user@$host:/tmp/
        ssh -p $port  $user@$host "sudo cp /tmp/$file $filepash;sudo sed -i s/NetworkTest/\`hostname\`/g $filepash/$file"
        ssh -p $port  $user@$host "sudo sed -i s/NetworkTest/\`hostname\`/g $filepash/$file"
    }
    
restartsmk()
    {
        local port=$1
        local user=$2
        local host=$3
        ssh -p $port $user@$host "sudo a2enmod cgid; sudo service smokeping restart;sudo  service apache2 restart"
    }

    #Copyfile 22 Targets ubuntu host /etc/smokeping/config.d
    #restartsmk 22 ubuntu host

    for i in `cat smk.csv | egrep -v '^#|^$'`
        do
            echo $i
            {
            if echo $i | egrep -q -i 'al|google'
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
             Copyfile Targets 22 $user  $host /etc/smokeping/config.d
             restartsmk 22 $user $host
             }&
        done

