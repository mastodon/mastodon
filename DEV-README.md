# Development Environment Setup Guide

## For Linux

**TODO:** If you set up the environment on Linux, please document it here.

## For Windows

You need to install:

* Ruby 2.3.1
* Ruby Dev Kit (http://rubyinstaller.org/downloads + https://github.com/oneclick/rubyinstaller/wiki/Development-Kit)
* Docker for Windows
* Redis for Windows (https://github.com/MSOpenTech/redis/releases)
* Postgres for Windows (http://www.enterprisedb.com/products-services-training/pgdownload#windows)
* An IDE for Ruby dev (Visual Studio Code w/ Ruby extension seems okay?)

Once you're at a prompt in a working copy of Mastodon:

* Make sure you have set up the Ruby Dev Kit as per instructions on their GitHub
* Change the `postgres` user password to an empty string with `ALTER USER postgres PASSWORD '';`.  You can do this from pgAdmin after installing Postgres
* Run the following commands, changing out `set` for `export` if running from Git bash:

```
set REDIS_HOST=localhost
set REDIS_PORT=6379
set DB_HOST=localhost
set DB_USER=postgres
set DB_NAME=postgres
set DB_PASS=
set DB_PORT=5432
set NEO4J_HOST=localhost
set NEO4J_PORT=7474
set LOCAL_DOMAIN=localhost
set LOCAL_HTTPS=false
set PAPERCLIP_SECRET=
set SECRET_KEY_BASE=
set SMTP_SERVER=smtp.mailgun.org
set SMTP_PORT=587
set SMTP_LOGIN=
set SMTP_PASSWORD=
set SMTP_FROM_ADDRESS=notifications@example.com
```

* Run `docker-compose build`.  We use this to build the `neo4j` image (while we run Redis and Postgres on the Windows host).
* Run `docker run -p 7474:7474 neo4j`.  You'll need to run this command again if you restart your machine.
* Run `export RAILS_ENV=development` or `set RAILS_ENV=development`.
* Run `gem install pg --pre`
* Run `gem list pg`
* Replace `gem 'pg'` with `gem 'pg', '~> 0.19.0'` in Gemfile
* Replace all instances of `0.18.4` with `0.19.0` in Gemfile.lock
* Add `gem 'tzinfo-data'` to Gemfile
* `bundle install`
  * If you don't have Bundler, try the following:
  * `gem install bundler`
  * If you get HTTPS errors installing Bundler, try the following:
  * Download `https://curl.haxx.se/ca/cacert.pem` and save as `C:\Ruby23-x64\cacert.pem`
  * If using Git for Windows, run `export SSL_CERT_FILE='C:\Ruby23-x64\cacert.pem'`
  * If using Command Prompt, run `set SSL_CERT_FILE=C:\Ruby23-x64\cacert.pem`
  * Then `gem install bundler` again
* Run `rails db:migrate`

**TODO** Figure out why `rails db:migrate` bails with:

```
WARNING: could not load hiredis extension, using (slower) pure Ruby implementation.
rails aborted!
PG::ConnectionBad: fe_sendauth: no password supplied
bin/rails:4:in `require'
bin/rails:4:in `<main>'
Tasks: TOP => db:migrate
(See full trace by running task with --trace)
```

I'm pretty sure it's not picking up the database configuration correctly.