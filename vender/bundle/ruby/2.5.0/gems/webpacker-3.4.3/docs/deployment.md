# Deployment


Webpacker hooks up a new `webpacker:compile` task to `assets:precompile`, which gets run whenever you run `assets:precompile`. 
If you are not using Sprockets `webpacker:compile` is automatically aliased to `assets:precompile`. Remember to set NODE_ENV environment variable to production during deployment or when running the rake task.

The `javascript_pack_tag` and `stylesheet_pack_tag` helper method will automatically insert the correct HTML tag for compiled pack. Just like the asset pipeline does it.

By default the output will look like this in different environments:

```html
  <!-- In development mode with webpack-dev-server -->
  <script src="http://localhost:8080/calendar-0bd141f6d9360cf4a7f5.js"></script>
  <link rel="stylesheet" media="screen" href="http://localhost:8080/calendar-dc02976b5f94b507e3b6.css">
  <!-- In production or development mode -->
  <script src="/packs/calendar-0bd141f6d9360cf4a7f5.js"></script>
  <link rel="stylesheet" media="screen" href="/packs/calendar-dc02976b5f94b507e3b6.css">
```


## Heroku

Heroku installs Yarn and node by default if you deploy a Rails app with
Webpacker so all you would need to do:

```bash
heroku create shiny-webpacker-app
heroku addons:create heroku-postgresql:hobby-dev
git push heroku master
```


## Nginx

Webpacker doesn't serve anything in production. You’re expected to configure your web server to serve files in public/ directly.

Some servers support sending precompressed versions of files with the `.gz` extension when they're available. For example, nginx offers a `gzip_static` directive.

Here's a sample nginx site config for a Rails app using Webpacker:

```nginx
upstream app {
  # ...
}

server {
  server_name www.example.com;
  root /path/to/app/public;

  location @app {
    proxy_pass http://app;
    proxy_redirect off;

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }

  location / {
    try_files $uri @app;
  }

  location ^~ /packs/ {
    gzip_static on;
    expires max;
  }
}
```

## CDN

Webpacker out-of-the-box provides CDN support using your Rails app `config.action_controller.asset_host` setting. If you already have [CDN](http://guides.rubyonrails.org/asset_pipeline.html#cdns) added in your Rails app
you don't need to do anything extra for Webpacker, it just works.
