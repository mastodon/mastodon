# Local OpenLDAP Integration Testing

Set up a [Vagrant](http://www.vagrantup.com/) VM to run integration
tests against OpenLDAP locally. *NOTE*: To support some of the SSL tests,
Vagrant forwards localhost port 9389 to VM host port 9389. The port mapping
goes away when you run `vagrant destroy`.

## Install Vagrant

*NOTE*: The Vagrant gem (`gem install vagrant`) is
[no longer supported](https://www.vagrantup.com/docs/installation/). If you've
previously installed it, run `gem uninstall vagrant`. If you're an rbenv
user, you probably want to follow that up with `rbenv rehash; hash -r`.

If you use Homebrew on macOS:
``` bash
$ brew update
$ brew cask install virtualbox
$ brew cask install vagrant
$ brew cask install vagrant-manager
$ vagrant plugin install vagrant-vbguest
```

Installing Vagrant and virtualbox on other operating systems is left
as an exercise to the reader. Note the `vagrant-vbguest` plugin is required
to update the VirtualBox guest extensions in the guest VM image.

## Run the tests

``` bash
# start VM (from the correct directory)
$ cd test/support/vm/openldap/
$ vagrant up

# get the IP address of the VM
$ ip=$(vagrant ssh -- "ifconfig eth1 | grep -o -E '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -n1")

# change back to root project directory
$ cd ../../../..

# set the TCP port for testing
$ export INTEGRATION_PORT=9389

# run all tests, including integration tests
$ time INTEGRATION=openldap INTEGRATION_HOST=$ip bundle exec rake

# run a specific integration test file
$ time INTEGRATION=openldap INTEGRATION_HOST=$ip bundle exec ruby test/integration/test_search.rb

# run integration tests by default
$ export INTEGRATION=openldap
$ export INTEGRATION_HOST=$ip

# now run tests without having to set ENV variables
$ time bundle exec rake

# Once you're all done
$ cd test/support/vm/openldap
$ vagrant destroy
```

If at any point your VM appears to have broken itself, `vagrant destroy`
from the `test/support/vm/openldap` directory will blow it away. You can
then do `vagrant up` and start over.
