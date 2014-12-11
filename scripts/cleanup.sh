#!/bin/sh -ex


yum -y install cloud-init
echo "==> Cleaning up yum cache of metadata and packages to save space"
yum -y clean all

rm -rf /tmp/*

rm -f /etc/udev/rules.d/70-persistent-net.rules


#sed -i 's|^disable_root:.*|disable_root: 0|g' /etc/cloud/cloud.cfg
#sed -i 's|^ssh_pwauth:.*|ssh_pwauth: 1|g' /etc/cloud/cloud.cfg


fstrim -v /
