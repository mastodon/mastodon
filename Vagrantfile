# -*- mode: ruby -*-
# vi: set ft=ruby :

$provision = <<SCRIPT

cd /vagrant # This is where the host folder/repo is mounted

# Add the yarn repo + yarn repo keys
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
sudo apt-add-repository 'deb https://dl.yarnpkg.com/debian/ stable main'

# Add repo for NodeJS
curl -sL https://deb.nodesource.com/setup_4.x | sudo bash -

# Add firewall rule to redirect 80 to 3000 and save
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 3000
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt-get install iptables-persistent -y

# Add packages to build and run Mastodon
sudo apt-get install \
  git-core \
  g++ \
  libpq-dev \
  libxml2-dev \
  libxslt1-dev \
  imagemagick \
  nodejs \
  redis-server \
  redis-tools \
  postgresql \
  postgresql-contrib \
  yarn \
  libreadline-dev \
  -y

# Install rvm
cd /vagrant
read RUBY_VERSION < .ruby-version
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable --ruby=$RUBY_VERSION
source /home/vagrant/.rvm/scripts/rvm

# Configure database
sudo -u postgres createuser -U postgres vagrant -s
sudo -u postgres createdb -U postgres mastodon_development

# Install gems and node modules
gem install bundler
bundle install
yarn install

# Build Mastodon
export $(cat ".env.vagrant" | xargs)
bundle exec rails db:setup
bundle exec rails assets:precompile

SCRIPT

$start = <<SCRIPT

cd /vagrant
export $(cat ".env.vagrant" | xargs)
rails s -d -b 0.0.0.0

SCRIPT

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "ubuntu/trusty64"

  config.vm.provider :virtualbox do |vb|
    vb.name = "mastodon"
    vb.customize ["modifyvm", :id, "--memory", "1024"]

    # Disable VirtualBox DNS proxy to skip long-delay IPv6 resolutions.
    # https://github.com/mitchellh/vagrant/issues/1172
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]

    # Use "virtio" network interfaces for better performance.
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
    vb.customize ["modifyvm", :id, "--nictype2", "virtio"]

  end

  config.vm.hostname = "mastodon.dev"

  # This uses the vagrant-hostsupdater plugin, and lets you
  # access the development site at http://mastodon.dev.
  # To install:
  #   $ vagrant plugin install vagrant-hostsupdater
  if defined?(VagrantPlugins::HostsUpdater)
    config.vm.network :private_network, ip: "192.168.42.42", nictype: "virtio"
    config.hostsupdater.remove_on_suspend = false
  end

  if config.vm.networks.any? { |type, options| type == :private_network }
    config.vm.synced_folder ".", "/vagrant", type: "nfs", mount_options: ['rw', 'vers=3', 'tcp']
  else
    config.vm.synced_folder ".", "/vagrant"
  end

  # Otherwise, you can access the site at http://localhost:3000
  config.vm.network :forwarded_port, guest: 80, host: 3000

  # Full provisioning script, only runs on first 'vagrant up' or with 'vagrant provision'
  config.vm.provision :shell, inline: $provision, privileged: false

  # Start up script, runs on every 'vagrant up'
  config.vm.provision :shell, inline: $start, run: 'always', privileged: false

end
