#!/bin/bash
PKGSRC=cd
VBOX='VBOX'
date > /etc/vagrant_box_build_time

HOSTNAME=
VUSER=vagrant
VPASS=vagrant
VGROUP=vagrant

KEYMAP=us
ZONE=America
SUB_ZONE=NEW_YORK
LOCALE="en_US"
LOCALE_8859="$LOCALE ISO-8859"
LOCALE_UTF8="$LOCALE.UTF-8"

CHROOT=/mnt
PAC_BASE="base base-devel"
PAC_GRUB="grub-bios os-prober"
PAC_1="systemd sudo vim linux-headers make gcc openssh git ruby yajl zsh glibc pkg-config fakeroot"

DEVICE=/dev/sda
PART1=/dev/sda1
PART1LABEL='swapfs'
PART1TYPE=S
PART1START=0
PART1SIZE=512
PART1BOOT=
PART2=/dev/sda2
PART2LABEL='rootfs'
PART2TYPE=L
PART2START=
PART2SIZE=
PART2SIZE=
PART2BOOT=
PARTUNIT="-uM"
DOSVAR="--DOS"

#only Grub2 for now
BOOTLOADER=Grub2
GRUBTARGET="-i386-pc"

print_header(){
  printf "%$(tput cols)s\n"|tr ' ' '-'
  [[ $# -gt 0 ]] && printf "$1\n"
  printf "%$(tput cols)s\n"|tr ' ' '-'
}

pause(){ #{{{
  printf "%$(tput cols)s\n"|tr ' ' '-'
  read -e -sn 1 -p "Press any key to continue..."
}

#todo:
# - update pacman-key?
# - hostname/hosts
# - .vbox_version
# - unmount before reboot?

# INSTALL TASKS
#   https://github.com/helmuthdu/aui/blob/master/aui
# configure_keymap
# select_editor
# configure_mirrorlist
# create_partition
# format_device
# install_base_system
# configure_fstab
# configure_hostname
# configure_timezone
# configure_hardwareclock
# configure_locale
# configure_mkinitcpio
# install_bootloader
# configure_bootloader
# root_password

print_header "loading keymap..."
loadkeys $KEYMAP
#reflector to alter mirrors

print_header "partitioning disk..."
sfdisk $PARTUNIT $DEVICE $DOSVAR <<EOF
  $PART1START,$PART1SIZE,$PART1TYPE,$PART1BOOT
  $PART2START,$PART2SIZE,$PART2TYPE,$PART2BOOT
EOF

print_header "formatting disk..."
mkswap $PART1 -L $PART1LABEL
mkfs.ext4 $PART2 -L $PART2LABEL

print_header "mounting disk..."
swapon $PART1
mount -t ext4 $PART2 $CHROOT

print_header "installing base, base-devel, grub-bios and os-prober..."
pacstrap $CHROOT $PAC_BASE
pacstrap $CHROOT $PAC_GRUB

print_header "generating fstab..."
genfstab -p $CHROOT >> $CHROOT/etc/fstab

print_header "setting vconsole.conf..."
echo "KEYMAP=$KEYMAP" > $CHROOT/etc/vconsole.conf
echo "FONT=\"\"" > $CHROOT/etc/vconsole.conf
echo "FONT_MAP=\"\"" > $CHROOT/etc/vconsole.conf

#hostname
#echo $HOSTNAME > $CHROOT/etc/hostname
#configure /etc/hosts

# why is this file sometimes missing
# [[ $VBOX == 'VBOX' ]] && /bin/cp -f /root/.vbox_version $CHROOT/root/.vbox_version

print_header "setting timezone and locale..."
# chroot $CHROOT ln -s /usr/share/zoneinfo/$ZONE/$SUB_ZONE /etc/localtime
chroot $CHROOT echo "$ZONE/$SUBZONE" > /etc/timezone
echo 'LANG="'$LOCALE_UTF8'"' > $CHROOT/etc/locale.conf
chroot $CHROOT sed -i '/'$LOCALE'/s/^#//' /etc/locale.gen
hwclock --systohc --utc

print_header "chrooting into new system..."
arch-chroot $CHROOT <<ENDCHROOT
# cd $CHROOT/arch
# mount -t proc proc proc/
# mount -t sysfs sys sys/
# mount -o bind /dev dev/
# mount -t devpts pts dev/pts/

print_header "configuring initial ram disk for kernel..."
mkinitcpio -p linux

print_header "configuring grub bootloader..."
modprobe dm-mod
grub-install --recheck --debug $DEVICE
grub-mkconfig -o /boot/grub/grub.cfg
# grub-install --target=i386-pc --recheck $DEVICE
# grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch_grub --recheck
# grub-install --root-directory=$CHROOT --boot-directory=$CHROOT/boot --target=$GRUBTARGET $DEVICE

print_header "configuring bootloader locale..."
mkdir -p /boot/grub/locale
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
# vim $CHROOT/boot/grub/grub.cfg

print_header "adding pacages..."
pacman -S --noconfirm $PAC_1

print_header "enabling services..."
systemctl enable sshd
systemctl enable dhcp

print_header "setting root password..."
passwd<<EOF
$VUSER
$VPASS
EOF

print_header "setting up vagrant user..."
groupadd vagrant
useradd -m -g vagrant -r vagrant
passwd vagrant<<EOF
$VUSER
$VPASS
EOF

#config sudo
#echo 'root    ALL=(ALL)    ALL' >> /etc/sudoers
# vagrant user?

#open ssh
print_header "configuring hosts.allow and hosts.deny..."
echo "sshd:	ALL" > /etc/hosts.allow
echo "ALL:	ALL" > /etc/hosts.deny

print_header "configuring ssh key for vagrant user..."
mkdir /home/$VUSER/.ssh
chmod 700 /home/$VUSER/.ssh
curl 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' > /home/$VUSER/.ssh/authorized_keys
chmod 600 /home/$VUSER/.ssh/authorized_keys
chown -R $VUSER /home/$VUSER/.ssh

print_header "upgrading pacman..."
pacman-db-upgrade
print_header "waka waka..."
pacman -Syy --noconfirm

print_header "installing chef..."
gem install --no-ri --no-rdoc chef facter

print_header "installing puppet..."
chroot $CHROOT groupadd puppet
cd /tmp
git clone https://github.com/puppetlabs/puppet.git
cd puppet
ruby install.rb --bindir=/usr/bin --sbindir=/sbin

ENDCHROOT

# and reboot!
reboot

#OTHER PACKAGES
#PAC_SYSD="systemd systemd-sysvcompat systemd-arch-units"
#PAC_DBUS="dbus"
#PAC_RAR="rar"
#PAC_AVAHI="avahi nss-mdns"
#PAC_ALSA="alsa-utils alsa-plugins"
#PAC_OSSH="openssh"
#PAC_GCC="make gcc"
#PAC_NTFS "ntfs-3g ntfsprogs dosfstools exfat-utils fuse fuse-exfat"