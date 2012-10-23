Veewee::Session.declare({
  :cpu_count => '1', :memory_size=> '256', 
  :disk_size => '10140', :disk_format => 'VDI',:hostiocache => 'off',
  :os_type_id => 'ArchLinux_64',
  :iso_file => "archlinux-2012.10.06-dual.iso",
  :iso_src => "http://mirror.cc.columbia.edu/pub/linux/archlinux/iso/2012.10.06/archlinux-2012.10.06-dual.iso",
  :iso_md5 => "9e9057702af5826a3b924233bf44fe66",
  :iso_download_timeout => "1000",
  :boot_wait => "15", :boot_cmd_sequence => [
    '<Enter>',
    '<Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait>',
    '<Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait>',
    '<Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait>',
    'dhcpcd eth0<Enter><Wait><Wait>',

    'echo "sshd: ALL" > /etc/hosts.allow<Enter>',

    'passwd<Enter>',
    'vagrant<Enter>',
    'vagrant<Enter>',

    'gdisk /dev/sda<Enter><Wait>',
    'o<Enter>Y<Enter><Wait>', #create new MBR
    'n<Enter><Enter><Enter>+100M<Enter><Enter><Wait>', #/boot
    'c<Enter>1<Enter>Boot<Enter>',
    'n<Enter><Enter><Enter>+512M<Enter>8200<Enter><Wait>', #/swap
    'c<Enter>2<Enter>Swap<Enter>',
    'n<Enter><Enter><Enter><Enter><Enter><Wait>', #/root
    'c<Enter>3<Enter>FS<Enter>',
    'w<Enter><Wait>Y<Enter><Wait><Wait><Wait>'

    '/etc/rc.d/sshd start<Enter><Wait>',
  ],
  :kickstart_port => "7122", :kickstart_timeout => "10000", :kickstart_file => "aif.cfg",
  :ssh_login_timeout => "10000", :ssh_user => "root", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "sh '%f'",
  :shutdown_cmd => "shutdown -h now",
  :postinstall_files => [ "postinstall.sh", "postinstall2.sh"], :postinstall_timeout => "10000"
})
