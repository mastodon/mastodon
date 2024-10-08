# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV["PORT"] ||= "3000"

$provisionA = <<SCRIPT

# Add the yarn repo + yarn repo keys
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
sudo apt-add-repository 'deb https://dl.yarnpkg.com/debian/ stable main'

# Add repo for NodeJS
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt-get update

# Add firewall rule to redirect 80 to PORT and save
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port #{ENV["PORT"]}
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
  libicu-dev \
  libidn11-dev \
  libreadline6-dev \
  autoconf \
  bison \
  build-essential \
  ffmpeg \
  file \
  gcc \
  libffi-dev \
  libgdbm-dev \
  libjemalloc-dev \
  libncurses5-dev \
  libprotobuf-dev \
  libssl-dev \
  libyaml-dev \
  pkg-config \
  protobuf-compiler \
  zlib1g-dev \
  -y

# Install rvm
sudo apt-add-repository -y ppa:rael-gc/rvm
sudo apt-get install rvm -y

sudo usermod -a -G rvm $USER

SCRIPT

$provisionElasticsearch = <<SCRIPT
# Install Elastic Search
sudo apt install openjdk-17-jre-headless -y
sudo wget -O /usr/share/keyrings/elasticsearch.asc https://artifacts.elastic.co/GPG-KEY-elasticsearch
sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/elasticsearch.asc] https://artifacts.elastic.co/packages/7.x/apt stable main" > /etc/apt/sources.list.d/elastic-7.x.list'
sudo apt update
sudo apt install elasticsearch -y

sudo systemctl daemon-reload
sudo systemctl enable --now elasticsearch

echo 'path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
network.host: 0.0.0.0
http.port: 9200
discovery.seed_hosts: ["localhost"]
cluster.initial_master_nodes: ["node-1"]
xpack.security.enabled: false' > /etc/elasticsearch/elasticsearch.yml

sudo systemctl restart elasticsearch

# Install Kibana
sudo apt install kibana -y
sudo systemctl enable --now kibana

echo 'server.host: "0.0.0.0"
elasticsearch.hosts: ["http://localhost:9200"]' > /etc/kibana/kibana.yml

sudo systemctl restart kibana

SCRIPT

$provisionB = <<SCRIPT

source "/etc/profile.d/rvm.sh"

# Install Ruby
read RUBY_VERSION < /vagrant/.ruby-version
rvm install ruby-$RUBY_VERSION --disable-binary

# Configure database
sudo -u postgres createuser -U postgres vagrant -s
sudo -u postgres createdb -U postgres mastodon_development

cd /vagrant # This is where the host folder/repo is mounted

# Install gems
gem install bundler foreman
bundle install

# Install node modules
sudo corepack enable
corepack prepare
yarn install

# Build Mastodon
export RAILS_ENV=development
export $(cat ".env.vagrant" | xargs)
bundle exec rails db:setup

# Configure automatic loading of environment variable
echo 'export RAILS_ENV=development' >> ~/.bash_profile
echo 'export $(cat "/vagrant/.env.vagrant" | xargs)' >> ~/.bash_profile

SCRIPT

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "ubuntu/focal64"

  config.vm.provider :virtualbox do |vb|
    vb.name = "mastodon"
    vb.customize ["modifyvm", :id, "--memory", "8192"]
    vb.customize ["modifyvm", :id, "--cpus", "3"]

    # Disable VirtualBox DNS proxy to skip long-delay IPv6 resolutions.
    # https://github.com/mitchellh/vagrant/issues/1172
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]

    # Use "virtio" network interfaces for better performance.
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
    vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
  end

  config.vm.provider :libvirt do |libvirt|
    libvirt.cpus = 3
    libvirt.memory = 8192
  end


  # This uses the vagrant-hostsupdater plugin, and lets you
  # access the development site at http://mastodon.local.
  # If you change it, also change it in .env.vagrant before provisioning
  # the vagrant server to update the development build.
  #
  # To install:
  #   $ vagrant plugin install vagrant-hostsupdater
  config.vm.hostname = "mastodon.local"

  if defined?(VagrantPlugins::HostsUpdater)
    config.vm.network :private_network, ip: "192.168.42.42", nictype: "virtio"
    config.hostsupdater.remove_on_suspend = false
  end

  if config.vm.networks.any? { |type, options| type == :private_network }
    config.vm.synced_folder ".", "/vagrant", type: "nfs", mount_options: ['rw', 'actimeo=1']
  else
    config.vm.synced_folder ".", "/vagrant"
  end

  # Otherwise, you can access the site at http://localhost:3000 and http://localhost:4000 , http://localhost:8080
  config.vm.network :forwarded_port, guest: 3000, host: 3000
  config.vm.network :forwarded_port, guest: 3035, host: 3035
  config.vm.network :forwarded_port, guest: 4000, host: 4000
  config.vm.network :forwarded_port, guest: 8080, host: 8080
  config.vm.network :forwarded_port, guest: 9200, host: 9200
  config.vm.network :forwarded_port, guest: 9300, host: 9300
  config.vm.network :forwarded_port, guest: 9243, host: 9243
  config.vm.network :forwarded_port, guest: 5601, host: 5601

  # Full provisioning script, only runs on first 'vagrant up' or with 'vagrant provision'
  config.vm.provision :shell, inline: $provisionA, privileged: false, reset: true
  # Run with elevated privileges for Elasticsearch installation
  config.vm.provision :shell, inline: $provisionElasticsearch, privileged: true
  config.vm.provision :shell, inline: $provisionB, privileged: false

  config.vm.post_up_message = <<MESSAGE
To start server
  $ vagrant ssh -c "cd /vagrant && bin/dev"
MESSAGE

end
