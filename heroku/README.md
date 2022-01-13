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
    OTP_SECRET=$(docker run --rm -it tootsuite/mastodon:latest bin/rake secret) \
    SECRET_KEY_BASE=$(docker run --rm -it tootsuite/mastodon:latest bin/rake secret) \
    $(docker run --rm -e OTP_SECRET=placeholder -e SECRET_KEY_BASE=placeholder -it tootsuite/mastodon:latest bin/rake mastodon:webpush:generate_vapid_key | xargs)
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

#### Federation

```
$ heroku config:set LIMITED_FEDERATION_MODE=true
```

#### Outgoing email

```
$ heroku config:set SMTP_SERVER= SMTP_LOGIN= SMTP_PASSWORD= SMTP_FROM_ADDRESS=
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
$ heroku ps:scale worker=1
```

### Debug

```
$ heroku console
$ heroku ps:exec
```