#!/bin/bash
# 长A 业务部署配置内网 ip 地址

rpm -ql jq > /dev/null 2>&1 || yum install jq -y > /dev/null 2>&1
netc=$(cat /etc/ppp/data/conf/.line_nics_info   |  jq .[].phy_nic | uniq | sed 's/\"//g')
ifcfg_netc="/etc/sysconfig/network-scripts/ifcfg-$netc"
sed -i 's/BOOTPROTO.*/BOOTPROTO=static/g' ${ifcfg_netc}
sed -i 's/ONBOOT.*/ONBOOT=yes/g' ${ifcfg_netc}
sed -i '/^IPADDR/d' ${ifcfg_netc}; echo "IPADDR=192.168.3.$[RANDOM%254+1]" >> ${ifcfg_netc}
ifdown $netc && ifup $netc && ifconfig $netc
