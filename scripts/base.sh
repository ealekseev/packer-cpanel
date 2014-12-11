#!/bin/bash -ex

yum -y upgrade  
cat <<EOF > /etc/resolv.conf
nameserver 2001:4860:4860::8888
nameserver 2001:4860:4860::8844
nameserver 8.8.8.8
nameserver 8.8.4.4
options timeout:2 attempts:1 rotate
EOF

cat <<EOF >  /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE="eth0"
BOOTPROTO=dhcp
NM_CONTROLLED="no"
PERSISTENT_DHCLIENT=1
ONBOOT="yes"
TYPE=Ethernet
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_PEERDNS=yes
IPV6_PEERROUTES=yes
IPV6_FAILURE_FATAL=yes
NAME="eth0"
EOF

yum -y install epel-release

: <<COMMENT
yum -y --enablerepo="epel" install cloud-init

sed -i 's|^disable_root:.*|disable_root: 0|g' /etc/cloud/cloud.cfg
sed -i 's|^ssh_pwauth:.*|ssh_pwauth: 1|g' /etc/cloud/cloud.cfg
COMMENT

ln --symbolic /dev/null /etc/udev/rules.d/80-net-name-slot.rules
sed -i 's|#UseDNS yes|UseDNS no|g' /etc/ssh/sshd_config
sed -i 's|GSSAPIAuthentication yes|GSSAPIAuthentication no|g'  /etc/ssh/sshd_config
sed -i 's|PasswordAuthentication no|PasswordAuthentication yes|g' /etc/ssh/sshd_config
sed -i 's|#PermitRootLogin yes|PermitRootLogin yes|g' /etc/ssh/sshd_config

cat <<EOF > /etc/fstab
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>          <options>                        <dump>  <pass>
/dev/sda1       /               ext4    defaults,relatime,discard,errors=panic      0       1
EOF

for p in dracut-config-rescue plymouth-scripts alsa-tools-firmware alsa-firmware plymouth plymouth-core-libs btrfs-progs iwl105-firmware iwl7260-firmware alsa xfsprogs iwl2030-firmware iwl6000g2b-firmware iwl2000-firmware iwl3160-firmware; do
    yum -y remove $p || :
done

yum -y install nano dracut

dracut -H --force

test -f /etc/selinux/config && sed -i 's|SELINUX=.*|SELINUX=disabled|g' /etc/selinux/config
