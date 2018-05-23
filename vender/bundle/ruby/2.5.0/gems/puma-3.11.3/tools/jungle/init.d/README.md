# Puma daemon service

Init script to manage multiple Puma servers on the same box using start-stop-daemon.

## Installation 

    # Copy the init script to services directory 
    sudo cp puma /etc/init.d
    sudo chmod +x /etc/init.d/puma
    
    # Make it start at boot time. 
    sudo update-rc.d -f puma defaults

    # Copy the Puma runner to an accessible location
    sudo cp run-puma /usr/local/bin
    sudo chmod +x /usr/local/bin/run-puma

    # Create an empty configuration file
    sudo touch /etc/puma.conf

## Managing the jungle 

Puma apps are held in /etc/puma.conf by default. It's mainly a CSV file and every line represents one app. Here's the syntax:

    app-path,user,config-file-path,log-file-path,environment-variables

You can add an instance by editing the file or running the following command:

    sudo /etc/init.d/puma add /path/to/app user /path/to/app/config/puma.rb /path/to/app/log/puma.log

The config and log paths, as well as the environment variables, are optional parameters and default to:

* config: /path/to/app/*config/puma.rb*
* log: /path/to/app/*log/puma.log*
* environment: (empty)

Multiple environment variables need to be separated by a semicolon, e.g.

    FOO=1;BAR=2

To remove an app, simply delete the line from the config file or run:

    sudo /etc/init.d/puma remove /path/to/app

The command will make sure the Puma instance stops before removing it from the jungle.

## Assumptions 

* The script expects a temporary folder named /path/to/app/*tmp/puma* to exist. Create it if it's not there by default.
The pid and state files should live there and must be called: *tmp/puma/pid* and *tmp/puma/state*.
You can change those if you want but you'll have to adapt the script for it to work.

* Here's what a minimal app's config file should have:

```
pidfile "/path/to/app/tmp/puma/pid"
state_path "/path/to/app/tmp/puma/state"
activate_control_app
```
