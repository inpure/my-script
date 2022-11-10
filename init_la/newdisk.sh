#!/bin/bash

a00_parted() {
    #boot=`lsblk|grep boot|grep -o sd[a-z]` # 存在磁盘非sd开头
    boot=$(df | grep -v centos-root | grep -E '/boot' | awk 'NR==1{print $1}' | cut -b 6-8)
    disk_num=$(lsblk | grep -o sd[a-z] | uniq | grep -v $boot | wc -l)
    disk=$(lsblk | grep -o sd[a-z] | uniq | grep -v $boot)
    if [ $disk_num -eq 2 ]; then
        for i in $disk; do
            parted -s /dev/$i mklabel gpt
            parted -s /dev/$i print
            echo "Ignore" | parted /dev/$i "mkpart 2  xfs 0  18%"
            echo "Ignore" | parted /dev/$i "mkpart 2  xfs 18% 36%"
            echo "Ignore" | parted /dev/$i "mkpart 2  xfs 36% 54%"
            echo "Ignore" | parted /dev/$i "mkpart 2  xfs 54% 72%"
            echo "Ignore" | parted /dev/$i "mkpart 2  xfs 72% 90%"
            echo "Ignore" | parted /dev/$i "mkpart 2  xfs 90% 100%"
            for k in {1..6}; do
                mkfs.xfs -f /dev/$i$k
            done
        done
    elif [ $disk_num -eq 3 ]; then
        for i in $disk; do
            parted -s /dev/$i mklabel gpt
            parted -s /dev/$i print
            echo "yes"
            echo "Ignore" | parted /dev/$i "mkpart 2  xfs 0  25%"
            echo "Ignore" | parted /dev/$i "mkpart 2  xfs 25% 50%"
            echo "Ignore" | parted /dev/$i "mkpart 2  xfs 50% 75%"
            echo "Ignore" | parted /dev/$i "mkpart 2  xfs 75% 100%"
            for k in {1..4}; do
                mkfs.xfs -f /dev/$i$k
            done
        done
    elif [ $disk_num -eq 6 ]; then
        for i in $disk; do
            parted -s /dev/$i mklabel gpt
            parted -s /dev/$i print
            echo "Ignore" | parted /dev/$i "mkpart 2  xfs 0  50%"
            echo "Ignore" | parted /dev/$i "mkpart 2  xfs 50% 100%"
            for k in {1..2}; do
                mkfs.xfs -f /dev/$i$k
            done
        done
    elif [ $disk_num -eq 4 ]; then
        for i in $disk; do
            parted -s /dev/$i mklabel gpt
            parted -s /dev/$i print
            echo "yes"
            echo "Ignore" | parted /dev/$i "mkpart 2  xfs 0  33%"
            echo "Ignore" | parted /dev/$i "mkpart 2  xfs 33% 66%"
            echo "Ignore" | parted /dev/$i "mkpart 2  xfs 66% 100%"
            for k in {1..3}; do
                mkfs.xfs -f /dev/$i$k
            done
        done
    else
        for i in $disk; do mkfs.xfs -f /dev/$i; done
    fi
}

a00_mount() {
    #boot=`lsblk|grep boot|grep -o sd[a-z]`
    boot=$(df | grep -v centos-root | grep -E '/boot' | awk 'NR==1{print $1}' | cut -b 6-8)
    disk_num=$(lsblk | grep -o sd[a-z] | uniq | grep -v $boot | wc -l)
    disk=$(lsblk | grep -o sd[a-z] | uniq | grep -v $boot)

    rm -rf /etc/mount.sh
    touch /etc/mount.sh && echo '#!/bin/bash' >/etc/mount.sh

    blkid | grep sd[a-z] | grep -v $boot | awk -F"\"" '{print $2}' >>/etc/mount.sh
    if [ $disk_num -eq 2 ] || [ $disk_num -eq 3 ] || [ $disk_num -eq 4 ] || [ $disk_num -eq 6 ]; then
        mkdir -p /data{1..12}/vod
    else
        mkdir -p /data{1..$disk_num}/vod
    fi
    
    mount_num=$(cat /etc/mount.sh | wc -l)
    k=1
    for i in $(seq 2 $mount_num); do
        txt=$(sed -n "${i}p" /etc/mount.sh)
        #decho $txt
        sed -i "s#${txt}#mount -U ${txt} /data${k}#g" /etc/mount.sh
        k=$(echo ${k}+1 | bc)
    done

    sh /etc/mount.sh
}

mkdir /data{1..12}
a00_parted
a00_mount
