#!/bin/bash
#改单线为多线

hn=`hostname`
hn=`echo $hn | sed -e 's/A00P/A00M/g'`
sed -i 's/A00P/A00M/g' /etc/hosts
echo $hn > /etc/hostname
echo $hn > /etc/salt/minion_id
echo "1" > /etc/is_multi_line
hostnamectl set-hostname --static $hn
sed -i '4s/[0-9]\{1,\}/1/g' /opt/soft/ipes/var/db/ipes/dcache-conf/dcache.xml
exit 0
