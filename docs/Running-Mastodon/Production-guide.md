Production guide
================

## Nginx

Regardless of whether you go with the Docker approach or not, here is an example Nginx server configuration:

```nginx
map $http_upgrade $connection_upgrade {
  default upgrade;
  ''      close;
}

server {
  listen 80;
  listen [::]:80;
  server_name example.com;
  return 301 https://$host$request_uri;
}

server {
  listen 443 ssl;
  server_name example.com;

  ssl_protocols TLSv1.2;
  ssl_ciphers EECDH+AESGCM:EECDH+AES;
  ssl_ecdh_curve prime256v1;
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:10m;

  ssl_certificate     /etc/letsencrypt/live/example.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

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
```

## Running in production without Docker

It is recommended to create a special user for mastodon on the server (you could call the user `mastodon`), though remember to disable outside login for it. You should only be able to get into that user through `sudo su - mastodon`.

## General dependencies

    sudo apt-get install imagemagick ffmpeg libpq-dev libxml2-dev libxslt1-dev nodejs file git curl
    curl -sL https://deb.nodesource.com/setup_4.x | sudo bash -

    sudo apt-get install nodejs

    sudo npm install -g yarn

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

Then once `rbenv` is ready, run `rbenv install 2.4.1` to install the Ruby version for Mastodon.

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

This allows you to `sudo systemctl enable /etc/systemd/system/mastodon-*.service` and `sudo systemctl start mastodon-web.service mastodon-sidekiq.service mastodon-streaming.service` to get things going.

## Cronjobs

I recommend creating a couple cronjobs for the following tasks:

- `RAILS_ENV=production bundle exec rake mastodon:media:clear`
- `RAILS_ENV=production bundle exec rake mastodon:push:refresh`
- `RAILS_ENV=production bundle exec rake mastodon:feeds:clear`

You may want to run `which bundle` first and copypaste that full path instead of simply `bundle` in the above commands because cronjobs usually don't have all the paths set. The time and intervals of when to run these jobs are up to you, but once every day should be enough for all.

You can edit the cronjob file for the `mastodon` user by running `sudo crontab -e -u mastodon` (outside of the mastodon user).

## Things to look out for when upgrading Mastodon

You can upgrade Mastodon with a `git pull` from the repository directory. You may need to run:

- `RAILS_ENV=production bundle exec rails db:migrate`
- `RAILS_ENV=production bundle exec rails assets:precompile`

Depending on which files changed, e.g. if anything in the `/db/` or `/app/assets` directory changed, respectively. Also, Mastodon runs in memory, so you need to restart it before you see any changes. If you're using systemd, that would be:

    sudo systemctl restart mastodon-*.service
