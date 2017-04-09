Production guide
================

## Running in production without Docker

It is recommended to create a special user for mastodon on the server (you could call the user `mastodon`), though remember to disable outside login for it. You should only be able to get into that user through `sudo su - mastodon`.

    $ adduser mastodon sudo
    $ echo "DenyUsers mastodon" >> /etc/ssh/sshd_config
    $ sudo systemctl restart ssh
    $ sudo su - mastodon

Now, if you try to ssh in as mastodon you'll fail - but if you ssh in as the root user (or whatever login account you're using) and do `su - mastodon` it should work.

## General dependencies

    sudo apt-get install imagemagick ffmpeg libpq-dev libxml2-dev libxslt1-dev nodejs file git curl
    curl -sL https://deb.nodesource.com/setup_4.x | sudo bash -

    sudo apt-get install nodejs

    sudo npm install -g yarn

## Nginx w/ HTTPS via LetsEncrypt
First, make sure your domain name is either pointing to your server's IP via A record, or to its hostname via CNAME record. Or, if you have a hosting setup where you can just set the DNS servers entirely, use that. Regardless, your DNS has to be configured before LetsEncrypt will work.

### LetsEncrypt (SSL is free and easy, do this!)
Go to https://certbot.eff.org/ to get setup instructions for your server configuration. If you're following this guide, you want the nginx setup - and for the purposes of this example, let's assume you're running on Ubuntu 16.04. (If you're not the instructions may slightly vary - follow what it says on the website instead of what it says here).

Certbot tells us to:

    sudo add-apt-repository ppa:certbot/certbot
    sudo apt-get update
    sudo apt-get install certbot 

Depending on your Ubuntu image, you may first need to run: 

    sudo apt-get install software-properties-common python-software-properties

Once that's installed, run:

    certbot certonly

and follow the prompts. It'll ask you what domain name you want to get a certificate for - put in the public facing domain name, which should be the same as your instance name. The one you set up DNS for. This installer is cool, it has the ability to stand up a temporary webserver on your host that it will use to verify that you own the domain name you're claiming. Once this is done, great! You can provide HTTPS access!

### Nginx
To install nginx, run:

    sudo apt-get install nginx

Replace the default contents of `/etc/nginx/nginx.conf` with the following, where all four instances of the string `YOUR_HOST` are changed to the hostname for which you set up SSL above.

```
worker_processes  4;
#Refers to single threaded process. Generally set to be equal to the number of CPUs or cores.

#error_log  logs/error.log; #error_log  logs/error.log  notice;
#Specifies the file where server logs.

#pid        logs/nginx.pid;
#nginx will write its master process ID(PID).

events {
    worker_connections  1024;
    # worker_processes and worker_connections allows you to calculate maxclients value:
    # max_clients = worker_processes * worker_connections
}


http {
  include mime.types;
  map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
  }

  server {
    listen 80;
    listen [::]:80;
    server_name YOUR_HOST;
    return 301 https://$host$request_uri;
  }

  server {
    listen 443 ssl;
    server_name YOUR_HOST;

    ssl_protocols TLSv1.2;
    ssl_ciphers EECDH+AESGCM:EECDH+AES;
    ssl_ecdh_curve prime256v1;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;

    ssl_certificate     /etc/letsencrypt/live/YOUR_HOST/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/YOUR_HOST/privkey.pem;

    keepalive_timeout    70;
    sendfile             on;
    client_max_body_size 0;
    gzip off;

    root /home/mastodon/live/public;

    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";

    location / {
      try_files $uri @proxy;
    }

    location @proxy {
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto https;

      proxy_pass_header Server;

      proxy_pass http://localhost:3000;
      proxy_buffering off;
      proxy_redirect off;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $connection_upgrade;

      tcp_nodelay on;
    }

    location /api/v1/streaming {
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto https;

      proxy_pass http://localhost:4000;
      proxy_buffering off;
      proxy_redirect off;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $connection_upgrade;

      tcp_nodelay on;
    }

    error_page 500 501 502 503 504 /500.html;
  }
}
```

## Redis

    sudo apt-get install redis-server redis-tools

## Postgres

    sudo apt-get install postgresql postgresql-contrib

Setup a user and database for Mastodon:

    sudo su - postgres
    psql

In the prompt:

    CREATE USER mastodon CREATEDB;
    \q

## Rbenv

It is recommended to use rbenv (exclusively from the `mastodon` user) to install the desired Ruby version. Follow the guides to [install rbenv][1] and [rbenv-build][2] (I recommend checking the [prerequisites][3] for your system on the rbenv-build project and installing them beforehand, obviously outside the unprivileged `mastodon` user)

[1]: https://github.com/rbenv/rbenv#installation
[2]: https://github.com/rbenv/ruby-build#installation
[3]: https://github.com/rbenv/ruby-build/wiki#suggested-build-environment

Then once `rbenv` is ready, run `rbenv install 2.3.1` to install the Ruby version for Mastodon.

## Git

You need the `git-core` package installed on your system. If it is so, from the `mastodon` user:

    cd ~
    git clone https://github.com/tootsuite/mastodon.git live
    cd live

Then you can proceed to install project dependencies:

    gem install bundler
    bundle install --deployment --without development test
    yarn install

## Configuration

Then you have to configure your instance:

    cp .env.production.sample .env.production
    nano .env.production

Fill in the important data, like host/port of the redis database, host/port/username/password of the postgres database, your domain name, SMTP details (e.g. from Mailgun or equivalent transactional e-mail service, many have free tiers), whether you intend to use SSL, etc. If you need to generate secrets, you can use:

    rake secret

To get a random string. If you are setting up on one single server (most likely), then `REDIS_HOST` is localhost and `DB_HOST` is `/var/run/postgresql`, `DB_USER` is `mastodon` and `DB_NAME` is `mastodon_production` while `DB_PASS` is empty because this setup will use the ident authentication method (system user "mastodon" maps to postgres user "mastodon").

## Setup

And setup the database for the first time, this will create the tables and basic data:

    RAILS_ENV=production bundle exec rails db:setup

Finally, pre-compile all CSS and JavaScript files:

    RAILS_ENV=production bundle exec rails assets:precompile

## Systemd

Example systemd configuration for the web workers, to be placed in `/etc/systemd/system/mastodon-web.service`:

```systemd
[Unit]
Description=mastodon-web
After=network.target

[Service]
Type=simple
User=mastodon
WorkingDirectory=/home/mastodon/live
Environment="RAILS_ENV=production"
Environment="PORT=3000"
ExecStart=/home/mastodon/.rbenv/shims/bundle exec puma -C config/puma.rb
TimeoutSec=15
Restart=always

[Install]
WantedBy=multi-user.target
```

Example systemd configuration for the background workers, to be placed in `/etc/systemd/system/mastodon-sidekiq.service`:

```systemd
[Unit]
Description=mastodon-sidekiq
After=network.target

[Service]
Type=simple
User=mastodon
WorkingDirectory=/home/mastodon/live
Environment="RAILS_ENV=production"
Environment="DB_POOL=5"
ExecStart=/home/mastodon/.rbenv/shims/bundle exec sidekiq -c 5 -q default -q mailers -q pull -q push
TimeoutSec=15
Restart=always

[Install]
WantedBy=multi-user.target
```

Example systemd configuration file for the streaming API, to be placed in `/etc/systemd/system/mastodon-streaming.service`:

```systemd
[Unit]
Description=mastodon-streaming
After=network.target

[Service]
Type=simple
User=mastodon
WorkingDirectory=/home/mastodon/live
Environment="NODE_ENV=production"
Environment="PORT=4000"
ExecStart=/usr/bin/npm run start
TimeoutSec=15
Restart=always

[Install]
WantedBy=multi-user.target
```

This allows you to `sudo systemctl enable /etc/systemd/system/mastodon-*.service` and `sudo systemctl start mastodon-web.service mastodon-sidekiq.service mastodon-streaming.service` to get things going. If you haven't restarted nginx since modifying the config file, do that now as well: `sudo systemctl restart nginx`.

## Cronjobs

I recommend creating a couple cronjobs for the following tasks:

- `RAILS_ENV=production bundle exec rake mastodon:media:clear`
- `RAILS_ENV=production bundle exec rake mastodon:push:refresh`
- `RAILS_ENV=production bundle exec rake mastodon:feeds:clear`

You may want to run `which bundle` first and copypaste that full path instead of simply `bundle` in the above commands because cronjobs usually don't have all the paths set. The time and intervals of when to run these jobs are up to you, but once every day should be enough for all.

You can edit the cronjob file for the `mastodon` user by running `sudo crontab -e -u mastodon` (outside of the mastodon user).

## Monitoring (Optional)
You can monitor your server's status using [netdata](https://github.com/firehol/netdata/wiki/Installation)! Installation looks different depending on your OS - find details at their website, or follow along here if you're running Ubuntu 16.04:

    sudo apt-get install zlib1g-dev uuid-dev libmnl-dev gcc make git autoconf autoconf-archive autogen automake pkg-config curl
    git clone https://github.com/firehol/netdata.git --depth=1
    cd netdata
    ./netdata-installer.sh

Netdata should now be running on localhost:19999. To expose it via nginx we need to add a few rules to our nginx configuration.

1. Inside of the `http` directive, as a sibling to the various `server` directives we set up above, add this:
    ```
    upstream netdata {
        server 127.0.0.1:19999;
        keepalive 64;
    }
    ```

2. Inside of the `server` directive that's handling https, next to all of the other locations, add the following two:
    ```
    location /netdata {
      return 301 /netdata/;
    }

    location ~ /netdata/(?<ndpath>.*) {
      proxy_redirect off;
      proxy_set_header Host $host;

      proxy_set_header X-Forwarded-Host $host;
      proxy_set_header X-Forwarded-Server $host;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_http_version 1.1;
      proxy_pass_request_headers on;
      proxy_set_header Connection "keep-alive";
      proxy_store off;
      proxy_pass http://netdata/$ndpath$is_args$args;

      gzip on;
      gzip_proxied any;
      gzip_types *;
    }
    ```

Then `sudo systemctl restart nginx` and navigate to https://YOUR_DOMAIN/netdata to see realtime monitoring data.


## Things to look out for when upgrading Mastodon

You can upgrade Mastodon with a `git pull` from the repository directory. You may need to run:

- `RAILS_ENV=production bundle exec rails db:migrate`
- `RAILS_ENV=production bundle exec rails assets:precompile`

Depending on which files changed, e.g. if anything in the `/db/` or `/app/assets` directory changed, respectively. Also, Mastodon runs in memory, so you need to restart it before you see any changes. If you're using systemd, that would be:

    sudo systemctl restart mastodon-*.service
