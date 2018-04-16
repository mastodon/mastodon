# Puma as a service using Upstart

Manage multiple Puma servers as services on the same box using Ubuntu upstart.

## Installation 

    # Copy the scripts to services directory 
    sudo cp puma.conf puma-manager.conf /etc/init
    
    # Create an empty configuration file
    sudo touch /etc/puma.conf

## Managing the jungle 

Puma apps are referenced in /etc/puma.conf by default. Add each app's path as a new line, e.g.:

```
/home/apps/my-cool-ruby-app
/home/apps/another-app/current
```

Start the jungle running:

`sudo start puma-manager`

This script will run at boot time.

Start a single puma like this:

`sudo start puma app=/path/to/app`

## Logs

Everything is logged by upstart, defaulting to `/var/log/upstart`.

Each puma instance is named after its directory, so for an app called `/home/apps/my-app` the log file would be `/var/log/upstart/puma-_home_apps_my-app.log`.

## Conventions 

* The script expects:
  * a config file to exist under `config/puma.rb` in your app. E.g.: `/home/apps/my-app/config/puma.rb`.
  * a temporary folder to put the PID, socket and state files to exist called `tmp/puma`. E.g.: `/home/apps/my-app/tmp/puma`. Puma will take care of the files for you.

You can always change those defaults by editing the scripts.

## Here's what a minimal app's config file should have

```
pidfile "/path/to/app/tmp/puma/pid"
state_path "/path/to/app/tmp/puma/state"
activate_control_app
```

## Before starting...

You need to customise `puma.conf` to:

* Set the right user your app should be running on unless you want root to execute it!
  * Look for `setuid apps` and `setgid apps`, uncomment those lines and replace `apps` to whatever your deployment user is.
  * Replace `apps` on the paths (or set the right paths to your user's home) everywhere else.
* Uncomment the source lines for `rbenv` or `rvm` support unless you use a system wide installation of Ruby.
