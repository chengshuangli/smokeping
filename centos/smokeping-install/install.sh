#!/bin/bash
#note: This script is to install smokeping for CentOS

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export PATH

stop_firewall()
{
    /etc/init.d/iptables stop
    chkconfig --level 345 iptables off
    selinux=`getenforce`
    if [ ${selinux} = Enforcing ];then
        echo "SElinux is open,I will Stop It."
        setenforce 0
    fi    
}

stop_services()
{
     if [ -f /etc/init.d/sendmail ];then
            /etc/init.d/sendmail stop
            chkconfig --level 345 sendmail off
    else
            echo "sendmail not start!"
    fi
}

start_services()
{
    /etc/init.d/httpd stop
    /etc/init.d/httpd start
    chkconfig --level 345 httpd on
    /etc/init.d/smokeping stop
    /etc/init.d/smokeping start
    chkconfig --level 345 smokeping on
}

time_sync()
{
    if [ -f /var/spool/cron/root ];then
            if [ `grep "ntp.app.joy.cn" /var/spool/cron/root |wc -l` -eq 0 ];then
                echo "1 * * * * /usr/sbin/ntpdate ntp.app.joy.cn; hwclock -w 1>/dev/null 2>&1" >> /var/spool/cron/root
            fi
    else
            touch /var/spool/cron/root
            echo "1 * * * * /usr/sbin/ntpdate ntp.app.joy.cn; hwclock -w 1>/dev/null 2>&1" >> /var/spool/cron/root
    fi

}

install_packets()
{
        yum groupinstall -y Base
        yum install -y httpd httpd-devel gcc make perl-devel perl-Time-HiRes rrdtool-perl perl-CGI
       
        yum -y install libxml2-devel libpng-devel glib pango pango-devel freetype freetype-devel fontconfig cairo cairo-devel libart_lgpl  libart_lgpl-devel zlib-devel perl-ExtUtils-Embed perl-libwww-perl perl-CGI-SpeedyCGI                                                                                                
        cp -f ${current_dir}/httpd.conf /etc/httpd/conf/
        service    httpd start
        chkconfig httpd on
}


ins_rrdtool()
{
    cd ${current_dir}
    tar zxvf rrdtool-1.4.5.tar.gz
    cd rrdtool-1.4.5
    sed -i 's/setlocale(LC_NUMERIC, "C")/setlocale(LC_ALL, "zh_CN.gb2312")/g' src/rrd_graph.c
    ./configure --prefix=/usr/local/rrdtool --disable-ctl --disable-python
    make
    make install
}

ins_CGI()
{
    cd ${current_dir}
    tar zxvf CGI-SpeedyCGI-2.22.tar.gz
    cd  CGI-SpeedyCGI-2.22
    perl Makefile.PL
    #Compile mod_speedycgi(default no)? no
    make
    make install
}

ins_fping()
{
    cd ${current_dir}
    tar -xf fping.tar.tar
    cd fping-2.4b2_to
    ./configure --prefix=/usr/
    make
    make install

}

ins_smokeping()
{
        cd ${current_dir}
        if [ -d /usr/local/smokeping ];then
                rm -rf /usr/local/smokeping
        fi
        #local_ip=`ifconfig |grep "Bcast" |awk '{print $2}' |sed 's/addr://g' | tail -n 1`
        tar zxf smokeping.tar.gz  
        cp -a ${current_dir}/usr/local/smokeping/ /usr/local/
        cp -f ${current_dir}/config.dist /usr/local/smokeping/etc/
        chmod 4777 /bin/traceroute
        chmod 755 /etc/init.d/smokeping
}


main()
{
    stop_firewall
    stop_services
    time_sync
    install_packets
    ins_rrdtool
    ins_CGI
    ins_fping
    ins_smokeping
    start_services 
}


current_dir=`pwd`
sed -i 's/^LANG.*$/LANG="en_US.UTF-8"/g' /etc/sysconfig/i18n 
main
