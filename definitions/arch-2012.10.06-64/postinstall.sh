#!/bin/bash

# # var to determine package source
PKGSRC=cd
date > /etc/vagrant_box_build_time

#get hd info
DRIVE=/dev/sda
# SIZE=`fdisk -l $DRIVE | grep Disk | awk '{print $5}'`
# CYLINDERS=`sfdisk -d $DRIVE | grep Disk | awk '{print $3}'`
# HEADS=`sfdisk -d $DRIVE | grep Disk | awk '{print $5}'`
# SECTORS=`sfdisk -d $DRIVE | grep Disk | awk '{print $7}'`

#partition hd
# (leave space for MBR)
# 512 /swap
# x   rest
sfdisk -uM $DRIVE << EOF
1,512,S
,,L
EOF

#format partitions
mkfs.ext2 /dev/sda1 -L bootfs
mkswap /dev/sda2 -L swapfs
swapon /dev/sda2
mkfs.ext4 /dev/sda3 -L rootfs

#mount partitions
mkdir /mnt/boot
mount -t ext4 /dev/sda3 /mnt
mount -t ext2 /dev/sda1 /mnt/boot

pacstrap /mnt base base-devel sudo openssh vim ruby linux-headers make gcc yajl zsh

#generate fstab
genfstab -p /mnt >> /mnt/etc/fstab
arch-chroot /mnt pacman -S --noconfirm grub-bios

# launch automated install
#  (AIF removed from Arch)
# su -c 'aif -p automatic -c aif.cfg'

# copy over the vbox version file
/bin/cp -f /root/.vbox_version /mnt/root/.vbox_version

# chroot into the new system
# (these can be replaced with arch-chroot)
arch-chroot /mnt <<ENDCHROOT
#mount -o bind /dev /mnt/dev
#mount -o bind /sys /mnt/sys
#mount -t proc none /mnt/proc
#chroot /mnt <<ENDCHROOT

# # make sure network is up and a nameserver is available
dhcpcd eth0

# sudo setup
# note: do not use tabs here, it autocompletes and borks the sudoers file
cat <<EOF > /etc/sudoers
root    ALL=(ALL)    ALL
%wheel    ALL=(ALL)    NOPASSWD: ALL
EOF

# set up user accounts
passwd<<EOF
vagrant
vagrant
EOF
useradd -m -G wheel -r vagrant
passwd -d vagrant
passwd vagrant<<EOF
vagrant
vagrant
EOF

# create puppet group
groupadd puppet

# make sure ssh is allowed
echo "sshd:	ALL" > /etc/hosts.allow

# and everything else isn't
echo "ALL:	ALL" > /etc/hosts.deny

# make sure sshd starts
# rc.conf removed (now using systemd)
# sed -i 's:^DAEMONS\(.*\))$:DAEMONS\1 sshd):' /etc/rc.conf

# install mitchellh's ssh key
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
curl 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' > /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

# choose a mirror
# sed -i 's/^#\(.*leaseweb.*\)/\1/' /etc/pacman.d/mirrorlist

# update pacman
[[ $PKGSRC == 'cd' ]] && pacman -Syy
[[ $PKGSRC == 'cd' ]] && pacman -S --noconfirm pacman

# upgrade pacman db
pacman-db-upgrade
pacman -Syy

# install some packages
pacman -S --noconfirm glibc git pkg-config fakeroot
gem install --no-ri --no-rdoc chef facter
cd /tmp
git clone https://github.com/puppetlabs/puppet.git
cd puppet
ruby install.rb --bindir=/usr/bin --sbindir=/sbin

# set up networking
[[ $PKGSRC == 'net' ]] && sed -i 's/^\(interface=*\)/\1eth0/' /etc/rc.conf

# leave the chroot
ENDCHROOT

# take down network to prevent next postinstall.sh from starting too soon
/etc/rc.d/network stop

# and reboot!
reboot
