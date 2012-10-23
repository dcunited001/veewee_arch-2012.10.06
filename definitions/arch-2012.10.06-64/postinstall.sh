#!/bin/bash

# # var to determine package source
PKGSRC=cd
date > /etc/vagrant_box_build_time

#download base packages
pacstrap /mnt base base-devel sudo openssh vim ruby linux-headers make gcc yajl zsh glibc git pkg-config fakeroot

#generate fstab
genfstab -p /mnt >> /mnt/etc/fstab

#install grub
arch-chroot /mnt pacman -S --noconfirm grub-bios

# launch automated install
#  (AIF removed from Arch)
# su -c 'aif -p automatic -c aif.cfg'

# copy over the vbox version file
/bin/cp -f /root/.vbox_version /mnt/root/.vbox_version

# chroot into the new system
# => (these can be replaced with arch-chroot)
#   => (However, this is apparently not true...)
# arch-chroot /mnt <<ENDCHROOT
mount -o bind /dev /mnt/dev
mount -o bind /sys /mnt/sys
mount -t proc none /mnt/proc
chroot /mnt <<ENDCHROOT

# make sure network is up and a nameserver is available
dhcpcd eth0

# time/locale
ln -s /usr/share/zoneinfo/America/New_York /etc/localtime

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
# having problems with these packages now, installing above
#  (inappropriate ioctl for device?)
# pacman -S --noconfirm glibc git pkg-config fakeroot
gem install --no-ri --no-rdoc chef facter
cd /tmp
git clone https://github.com/puppetlabs/puppet.git
cd puppet
ruby install.rb --bindir=/usr/bin --sbindir=/sbin

# set up networking
# (this command blows up due to missing rc.conf, etc)
#   rc.conf has been removed, should i re-add package?
# [[ $PKGSRC == 'net' ]] && sed -i 's/^\(interface=*\)/\1eth0/' /etc/rc.conf

#build initial ram disk
# (requires /proc to be mounted)
mkinitcpio -p linux

# leave the chroot
ENDCHROOT

#install grub
grub-install --root-directory=/mnt/ --boot-directory=/mnt/boot --target=i386-pc /dev/sda
grub-mkconfig -o /mnt/boot/grub/grub.cfg

#modify bootloader config

# take down network to prevent next postinstall.sh from starting too soon
#   (Again, rc.conf has mostly been replaced with systemctl)
# /etc/rc.d/network stop

# and reboot!
reboot
