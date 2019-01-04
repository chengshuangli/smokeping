#!/bin/bash
##screen 运行此脚本
##网络测试使用
#set -o xtrace
## 为了更好的显示格式，vim编辑建议设置 vimrc echo "set ts=4" >> ~/.vimrc
basepath=$(dirname "$(readlink -f "$0")") #绝对路径
RESULTS=$basepath/results
[ -d $RESULTS ] || mkdir -p $RESULTS
CONF=$basepath/config.sh
source $CONF
Date=`date "+%Y%m%d%H"`

nmyip=`ip a  | grep global | awk '{print $2}' | head -n 1 | awk -F'/' '{print $1}'`
myip=$(curl icanhazip.com)
if [ -z $myip ]
    then
        myip=$nmyip
fi

echo $myip

if which traceroute > /dev/null 2>&1
##检查 traceroute 命令，没有就安装上
    then
        :
    else
        yum -y install traceroute >/dev/null 2>&1 || apt-get install -y traceroute >/dev/null 2>&1
fi

JieGuo=$basepath/${Date}-${myip}-Results.csv
##测试几天
#Days=4
##测试几秒
#Num_T=30

#nums=$((Days*24*3600))
nums=$(echo $Days*24*3600 | bc)
if [ $nums = 0 ]
    then
        nums=$Num_T
fi

echo $nums
echo "`date` start" > runlog.log

###处理ping
for i in `cat monitorIP.csv | egrep -a -v '^#|^$'`
    do
        {
            Monitor_nameip=$(echo "$i" | awk -F, '{print $1}')
            Monitor_ip=$(echo "$i" | awk -F, '{print $2}')
#            echo "ping -c $nums $Monitor_ip > $RESULTS/${Date}-${myip}-${Monitor_nameip}-${Monitor_ip}.txt"
            ping -c $nums $Monitor_ip > $RESULTS/${Date}-${myip}-${Monitor_nameip}-${Monitor_ip}.txt
            #echo "traceroute `traceroute -n  -w 1 -m 20  $Monitor_ip | grep -v '* * *' | grep -v '^$' | tail -n 1 | awk '{print $1}'`" >>$RESULTS/${Date}-${myip}-${Monitor_nameip}-${Monitor_ip}.txt
            traceroutenu=`traceroute -n  -w 1 -m 20  $Monitor_ip | grep -v '* * *' | grep -v '^$' | tail -n 1 | awk '{print $1}'`
            if echo $traceroutenu | grep -a -q trace
		then
			traceroutenu=0
	    fi
            echo "traceroute $traceroutenu" >>$RESULTS/${Date}-${myip}-${Monitor_nameip}-${Monitor_ip}.txt
         }&
    done

echo "Wating $nums senconds finished networks"
echo "Get results file in $JieGuo"

wait 

##处理结果
###
>$JieGuo
for i in `cat monitorIP.csv`
    do
        Monitor_nameip=$(echo "$i" | awk -F, '{print $1}')
        Monitor_ip=$(echo "$i" | awk -F, '{print $2}')
        Loss=$(cat $RESULTS/${Date}-${myip}-${Monitor_nameip}-${Monitor_ip}.txt | grep -a loss | awk '{print $6}')
        Ping=$(cat $RESULTS/${Date}-${myip}-${Monitor_nameip}-${Monitor_ip}.txt |  grep -a 'rtt' | awk -F'/' '{print $5}')
        Traceroute=$(cat $RESULTS/${Date}-${myip}-${Monitor_nameip}-${Monitor_ip}.txt |  grep -a 'traceroute' | awk '{print $2}')
        #echo "${myip},${Monitor_nameip},${Monitor_ip},$Loss,$Ping,$Traceroute" >> $JieGuo
        echo "${Monitor_nameip},${Monitor_ip},$Loss,$Ping,$Traceroute" >> $JieGuo
done

echo "`date` end" >> runlog.log
