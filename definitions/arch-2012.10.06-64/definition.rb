Veewee::Session.declare({
  :cpu_count => '1', :memory_size=> '256', 
  :disk_size => '10140', :disk_format => 'VDI',:hostiocache => 'off',
  :os_type_id => 'ArchLinux_64',
  :iso_file => "archlinux-2012.10.06-dual.iso",
  :iso_src => "http://mirror.cc.columbia.edu/pub/linux/archlinux/iso/2012.10.06/archlinux-2012.10.06-dual.iso",
  :iso_md5 => "9e9057702af5826a3b924233bf44fe66",
  :iso_download_timeout => "1000",
  :boot_wait => "5", :boot_cmd_sequence => [
    '<Enter>',
    '<Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait>',
    '<Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait>',
    '<Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait>',
    
    'passwd<Enter>',
    'vagrant<Enter>',
    'vagrant<Enter>',

    'dhcpcd eth0<Enter><Wait>',
    'echo "sshd: ALL" > /etc/hosts.allow<Enter><Wait>',
    'systemctl enable sshd.service<Enter><Wait>',
  ],
  # :kickstart_port => "7122", :kickstart_timeout => "10000", :kickstart_file => "aif.cfg",
  :ssh_login_timeout => "10000", :ssh_user => "root", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "sh '%f'",
  :shutdown_cmd => "shutdown -h now",
  :postinstall_files => [ "postinstall.sh", "postinstall2.sh"], :postinstall_timeout => "10000"
})
