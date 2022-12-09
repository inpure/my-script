#!/bin/bash
# 获取设备配置信息

#制造商
d_Manufacturer=$(dmidecode -t 1 |grep -E 'Manufacturer'|awk '{print $2}')
#设备名称
d_product=$(dmidecode -t 1 |grep -E 'Product Name'|awk -F: '{print $2}'|awk '{gsub(/^\s+|\s+$/, "");print}')
#cpu 型号
d_cpu=$(cat /proc/cpuinfo | grep 'model name' |uniq |awk -F: '{print $2}'|awk -F@ '{print $1}'|sed s/[[:space:]]//g)
#物理cpu个数
physical_cpu_num=$(cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l)
#内存大小
d_mem=$(cat /proc/meminfo | grep -i MemTotal | awk '{print int($2/1024/1000)}')"G"
#系统盘
disk_boot=$(df | grep -v centos-root | grep -E '/boot' | awk 'NR==1{print $1}' | cut -b 6-8)
#系统盘大小
disk_boot_capacity=$(lsblk -bd -o name,size /dev/$disk_boot | tail -n 1 |awk '{print int($2/1000/1000/1000)}')"G"
#数据盘数量
disk_num=$(lsblk | grep -o sd[a-z] | uniq | grep -v $disk_boot | wc -l)
#数据盘大小
disk_capacity=$(lsblk -bd -o name,size|grep -Ev "$disk_boot|sr|loop" |tail -n 1 | awk '{print int($2/1000/1000/1000/1000)}')"T"
#万兆网卡数量
get_nc_10G_num(){
    nc_10G=$(lspci | grep -i ethernet|grep -E '10-G|10G|10 G'|wc -l)
    if [ $nc_10G == 0 ];then
        nc_10G="非万兆口"
    elif [ $nc_10G == 1 ];then
        nc_10G="单口万兆"
    elif [ $nc_10G == 2 ];then
        nc_10G="双口万兆"
    elif [ $nc_10G == 3 ];then
        nc_10G="三口万兆"
    elif [ $nc_10G == 4 ];then
        nc_10G="四口万兆"
    elif [ $nc_10G == 5 ];then
        nc_10G="五口万兆"
    else
        nc_10G="多口万兆"
    fi
}
#系统盘类型
check_disk_type(){
    if [ $(cat /sys/block/$disk_boot/queue/rotational) == 1 ];then
      disk_type="HDD"
    else
      disk_type="SSD"
    fi
}

#磁盘接口
check_disk_itf(){
    smartctl -a /dev/$(lsblk | grep -o sd[a-z] | uniq | grep -v $disk_boot|head -n 1) |grep SAS > /dev/null 2>&1
    if [ $? == 0 ];then
      disk_itf="_SAS"
    else
      disk_itf="_SATA"
}

main(){
    get_nc_10G_num
    check_disk_type

    #echo "制造商：$d_Manufacturer"
    #echo "设备名称：$d_product"
    #echo "cpu 型号：$d_cpu"
    #echo "物理 cpu 个数：$physical_cpu_num"
    #echo "内存大小：$d_mem"
    #echo "系统盘大小：$disk_boot_capacity"
    #echo "系统盘类型：$disk_type"
    #echo "数据盘数量：$disk_num"
    #echo "数据盘大小：$disk_capacity"
    #echo "万兆网卡数量：$nc_10G"

    #企业微信公告格式
    echo "${d_Manufacturer} ${d_product}/${d_cpu}*${physical_cpu_num}/${d_mem}/${disk_boot_capacity}${disk_type}+${disk_capacity}${disk_itf}*${disk_num}"
}
main
