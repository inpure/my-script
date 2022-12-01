#/bin/bash
update_kernel() {
  rpm -qa | grep "kernel-5.4.119" || yum -y install http://120.233.19.189:9080/kernel-5.4.119-19.0006.tl2.x86_64.rpm
  sed -i '/^add_drivers/d' /etc/dracut.conf
  cat /etc/dracut.conf | grep ^add_drivers+="mpt3sas" || echo add_drivers+="mpt3sas" >>/etc/dracut.conf
  kernel_version='5.4.119-19-0006'
  dracut -f /boot/initramfs-$kernel_version.img $kernel_version
  grub2-mkconfig -o /boot/grub2/grub.cfg
  grub2-set-default "$(cat /boot/grub2/grub.cfg | grep menuentry | grep "5.4." | awk -F\' '{print $2}')"
  grub2-editenv list
  if (lsinitrd -k $kernel_version | grep mpt3sas); then
    echo "update success!"
#    reboot
  else
    echo "update error!!!!!!!"
    exit 2
  fi
}
update_kernel

uname -r
awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg
rpm -qa | grep kernel
#yum remove kernel-lt-devel-5.4.120-1.el7.elrepo.x86_64
cat /etc/grub2.cfg|grep kernel-lt-devel
grub2-set-default 1
