# -*- mode: ruby -*-
# vi: set ft=ruby :

$provision = <<SCRIPT

cd /vagrant # This is where the host folder/repo is mounted

# Add the yarn repo + yarn repo keys
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
sudo apt-add-repository 'deb https://dl.yarnpkg.com/debian/ stable main'

# Add repo for Ruby 2.3 binaries
sudo apt-add-repository ppa:brightbox/ruby-ng

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
  ruby-build \
  libpq-dev \
  libxml2-dev \
  libxslt1-dev \
  imagemagick \
  nodejs \
  ruby2.3 \
  ruby2.3-dev \
  ruby-switch \
  redis-server \
  redis-tools \
  postgresql \
  postgresql-contrib \
  yarn \
  -y

# Set Ruby 2.3 as 'ruby'
sudo ruby-switch --set ruby2.3

# Configure database
sudo -u postgres createuser -U postgres vagrant -s
sudo -u postgres createdb -U postgres mastodon_development

# Install gems and node modules
sudo gem install bundler
bundle install
yarn install

# Build Mastodon
bundle exec rails db:setup
bundle exec rails assets:precompile

SCRIPT

$start = <<SCRIPT

cd /vagrant
export $(cat ".env.vagrant" | xargs)
killall ruby2.3
rails s -d -b 0.0.0.0

SCRIPT

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "ubuntu/trusty64"

  config.vm.provider :virtualbox do |vb|
    vb.name = "mastodon"
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.vm.hostname = "mastodon.dev"

  # This uses the vagrant-hostsupdater plugin, and lets you
  # access the development site at http://mastodon.dev.
  # To install:
  #   $ vagrant plugin install hostsupdater
  if defined?(VagrantPlugins::HostsUpdater)
    config.vm.network :private_network, ip: "192.168.42.42"
    config.hostsupdater.remove_on_suspend = false
  end

  # Otherwise, you can access the site at http://localhost:3000
  config.vm.network :forwarded_port, guest: 80, host: 3000

  # Full provisioning script, only runs on first 'vagrant up' or with 'vagrant provision'
  config.vm.provision :shell, inline: $provision, privileged: false

  # Start up script, runs on every 'vagrant up'
  config.vm.provision :shell, inline: $start, run: 'always', privileged: false

end
