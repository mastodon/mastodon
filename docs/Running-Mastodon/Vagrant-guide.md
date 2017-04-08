Vagrant guide
=============

A quick way to get a development environment up and running is with Vagrant. You will need recent versions of [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) installed.

## Basic setup

Install the latest versions of Vagrant and VirtualBox for your operating systems, and then run:

    vagrant plugin install vagrant-hostsupdater

This is optional, but will update your 'hosts' file when you start the virtual machine, allowing you to access the site at http://mastodon.dev (instead of http://localhost:3000).

To create and provision a new virtual machine for Mastodon development:

    git clone git@github.com:tootsuite/mastodon.git
    cd mastodon
    vagrant up

**Note:** On Linux hosts, you will need to [enable NFS support](https://www.vagrantup.com/docs/synced-folders/nfs.html).

Running `vagrant up` for the first time will run provisioning, which will:

- Download the Ubuntu 14.04 base image, if there isn't already a copy on your machine
- Create a new VirtualBox virtual machine from that image
- Run the provisioning script (located inside the Vagrantfile), which installs the system packages, Ruby gems, and JS modules required for Mastodon
- Run the startup script

## Starting the server

The Vagrant box will automatically start after provisioning. It can be started in future with `vagrant up` from the mastodon directory.

Once the Ubuntu virtual machine has booted, it will run the startup script, which loads the environment variables from `.env.vagrant` and then runs `rails s -d -b 0.0.0.0`. This will start a Rails server. You can then access your development site at http://mastodon.dev (or at http://localhost:3000 if you haven't installed vagrants-hostupdater). By default, your development environment will have an admin account created for you to use - the email address will be `admin@mastodon.dev` and the password will be `mastodonadmin`.

To stop the server, simply run `vagrant halt`.

## Using the server

You should now have a working Mastodon instance, although it will not federate, as it is not publicly accessible. Should you need temporary federation for development and testing, see the Ngrok information in the [Development Guide](Development-guide.md).

By default, your instance's ActionMailer will use "Letter Opener Web" for email. This means that any email that would normally be sent, will instead be stored, and accessible at http://mastodon.dev/letter_opener - you can use this to verify a registered user account.

## Making changes/developing

You are able to set environment variables, which are used for Mastodon configuration, by editing the `.env.vagrant` file. Any changes you make will take effect after a Vagrant restart.

Vagrant has mounted your mastodon folder inside the virtual machine. This means that any change to the files in the folder(e.g. the Rails controllers or the React components in /app) should immediately take effect on the live server. This allows you to make and test changes, and create new commits, without ever needing to access the virtual machine.

Should you need to access the virtual machine (for example, to manually restart the Rails process without restarting the box), run `vagrant ssh` from the mastodon folder. You will now be logged in as the `vagrant` user on the VirtualBox Ubuntu VM. You will want to `cd /vagrant` to see the app folder.

## Debugging

You can find the Rails server logs in in the `log` folder, which will often have the information you need.

If your Mastodon instance or Vagrant box are really not behaving, you can re-run the provisioning process. Stop the box with `vagrant halt`, and then run `vagrant destroy` - this will delete the virtual machine. You may then run `vagrant up` to create a new box, and re-run provisioning.

## Testing

To run the `rspec` tests and `rubocop` style checker, you may either:

* Install the relevant gems locally, or
* SSH into the virtual machine, `cd /vagrant`, and then run the commands

## Support/help

If you are confused, or having any issues with the above, the Mastodon IRC channel ( irc.freenode.net #mastodon ) is a good place to find assistance.
