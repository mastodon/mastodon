# Hellō README

## Development Setup

Development setup links:

* https://docs.joinmastodon.org/dev/setup/
* https://docs.joinmastodon.org/admin/install/

### Clone the Hellō Mastodon Repo

* clone https://github.com/hellocoop/mastodon to a local folder
* checkout the `dev` branch
  * the `dev` branch was created from the `v4.0.2` tag of the upstream repo
  * when upstream releases a new version then `dev` will be rebased on that new stable version

### VirtualBox

* download platform specific version from https://www.virtualbox.org/wiki/Downloads
* use latest version: 7.0.4

#### MacOS

```shell
brew install --cask virtualbox
```

Questions:
* confirm this works
* what version gets installed?

### NFS

#### MacOS

* nothing to do

#### Linux

```shell
sudo apt install nfs-kernel-server
```

If NFS hangs or in general needs a restart:
```shell
sudo systemctl status nfs-server.service
```

### Vagrant

1. https://developer.hashicorp.com/vagrant/docs/installation
2. check latest version, dropdown to the right of page title
3. https://developer.hashicorp.com/vagrant/downloads

#### CLI Completion

See: https://developer.hashicorp.com/vagrant/docs/cli#autocompletion

```shell
vagrant autocomplete install --bash
```

or most likely for MacOS:
```shell
vagrant autocomplete install --zsh
```

#### vagrant-hostsupdater Plugin

```shell
vagrant plugin install vagrant-hostsupdater
```

### Start Mastodon

Copy `.env.hello.local` to `.env` and enter a client id and secret.

Start the virtual machine:
```shell
vagrant up
```

This might take a while as it downloads, compiles and installs many packages.

Finalise virtual machine setup (known issue that a few steps are missing):
```shell
vagrant ssh
cd /vagrant
gem install bundler:2.3.26 && bundle install && gem install foreman
exit
```

Start Mastodon:
```shell
vagrant ssh -c "cd /vagrant && foreman start"
```

You may want to create an alias for the above start command as it is needed after each `vagrant up`.

Use `vagrant halt` and `vagrant up` or `vagrant destroy` and `vagrant up` as needed.

### Use Mastodon

In your browser navigate to http://mastodon.local/

Admin account credentials:
* username: `admin@mastodon.local`
* password: `mastodonadmin`

Legacy sign-in form available at: http://mastodon.local/auth/sign_in

## Image building

To build the `hello-mastodon` image
`npm run docker`

To publish the `hellocoop/mastodon` image to Docker Hub
`./publish.sh`

`./version.sh` will increment the version in `HELLO_VERSION.txt`

