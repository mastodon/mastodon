## Mastodon on Heroku

### Setup

Create the heroku app:

```
$ heroku apps:create my-mastodon
$ heroku config:set LOCAL_DOMAIN=my-mastodon.herokuapp.com
```

Add buildpacks for required dependencies:

```
$ heroku buildpacks:add heroku/ruby
$ heroku buildpacks:add --index 1 heroku-community/apt
$ heroku buildpacks:add --index 1 heroku-community/nginx
```

Generate secrets:

```
$ heroku config:set \
    OTP_SECRET=$(RAILS_ENV=production bin/rake secret) \
    SECRET_KEY_BASE=$(RAILS_ENV=production bin/rake secret) \
    $(RAILS_ENV=production OTP_SECRET=placeholder SECRET_KEY_BASE=placeholder bin/rake mastodon:webpush:generate_vapid_key | xargs)
```

Create databases:

```
$ heroku addons:create heroku-postgresql:hobby-basic
$ heroku addons:create heroku-redis --as=REDIS
$ heroku addons:create heroku-redis --as=SIDEKIQ_REDIS
$ heroku addons:create heroku-redis --as=CACHE_REDIS
```

### Settings

#### Storage for uploaded user photos and videos

See [lib/tasks/mastodon.rake](https://github.com/mastodon/mastodon/blob/5ba46952af87e42a64962a34f7ec43bc710bdcaf/lib/tasks/mastodon.rake#L137) for environment variables available for Wasabi, Minio or Google Cloud Storage.

```
$ heroku config:set S3_ENABLED=true S3_BUCKET=bbb AWS_ACCESS_KEY_ID=xxx AWS_SECRET_ACCESS_KEY=yyy
```

#### Outgoing email

```
$ heroku config:set SMTP_SERVER= SMTP_LOGIN= SMTP_PASSWORD= SMTP_FROM_ADDRESS=
```

#### Disable federation (optional)

```
$ heroku config:set LIMITED_FEDERATION_MODE=true
```

#### ElasticSearch (optional)

```
$ heroku addons:create bonsai
$ heroku config:get BONSAI_URL
$ heroku config:set ES_ENABLED=true ES_HOST= ES_PORT= ES_USER= ES_PASS=
```

### Deploy

```
$ git push heroku HEAD:main
$ heroku open
$ heroku ps:scale worker=1
```

### Run Admin CLI commands

```
$ heroku run bash
> bin/tootctl command options
```

### Debug

```
$ heroku logs -t
$ heroku console
$ heroku ps:exec
```
