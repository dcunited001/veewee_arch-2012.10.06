Arch 2012-10-06
---------------

This is a basebox that I built, using VeeWee's arch2011 basebox
as a starting point.  May need to tweak a few things, but I'm hoping
to use this box as a base for a few other projects.

I like using Arch for VM's because you choose exactly which packages
are installed.  So you can get the VM to run as little as 256MB of mem.

#### Note - ISO not included:
> I did not include the Arch ISO file into the project.  Make sure you download this
> from a reputable source.  There are lots of sketchy search results.  The ISO I used
> is named **archlinux-2012.10.06-dual.iso**.

#### Note - Grub/Initramfs issues:
> Need to look into it further, but after the basebox is completed,
> it looks like there's a few issues with restarting the VM.  When GRUB appears,
> you'll need to select the second option, the fallback initramfs.  Otherwise, the box gets stuck
> when loading the initramfs.  

Set up:
=======
1. Install VirtualBox.  Vagrant now works with VBox 4.2.x.
2. Clone the project & `cd !$`
3. Run `bundle install` to install the vagrant/veewee gems
4. Check out the *definitions* folder to see the install scripts
5. Run `vagrant basebox list` at project root to see the basebox name.
6. At the root of the project, run `vagrant basebox build [name]`
7. Watch the script execute!  Adjust the wait times if necessary.
8. Multiple restarts are occasionally necessary, this is a typical rough point.
9. Use/Export your new vagrant box.

Notes:
======
Vagrant is the main tool.  Mostly, VeeWee adds the 'basebox' subcommand to vagrant:

#### List Vagrant Subcommands:

    vagrant

#### Start a Vagrant Box:

    vagrant up

#### List all Vagrant(VeeWee) Basebox Subcommands:

    vagrant basebox

#### Build a new Basebox with VeeWee:

    vagrant basebox build [name]

#### Validate that a Basebox was built correctly:

    # uses cucumber for BDD, sweet
    vagrant basebox validate [name]

#### Export a Basebox to a file which can be shared:

    # generates a self-contained box that can be shared:
    #   now anyone can `vagrant up [name]`
    vagrant basebox export [name]

#### To Import a Vagrant Box:

    vagrant box add [name] [filename]

#### To use an Imported Vagrant Box:

    vagrant init [name]
    vagrant up
    vagrant ssh

Resources:
==========
Check the VeeWee Github for available baseboxes.  Be aware that these projects
involve downloading an iso and other software from the net.  Don't trust just
any ISO and try to build your own Baseboxes.

#### Vagrant Github:
- https://github.com/mitchellh/vagrant

#### VeeWee Github:
- https://github.com/jedi4ever/veewee

#### Vagrant Guides:
- http://seletz.github.com/blog/2012/01/17/creating-vagrant-base-boxes-with-veewee/
- http://devops.me/2011/10/05/vagrant/

#### great resource for installing arch(desktop):
- https://github.com/helmuthdu/aui/blob/master/aui
