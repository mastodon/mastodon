# webpack-dev-server


## HTTPS

If you're using the `webpack-dev-server` in development, you can serve your packs over HTTPS
by setting the `https` option for `webpack-dev-server` to `true` in `config/webpacker.yml`,
then start the dev server as usual with `./bin/webpack-dev-server`.

Please note that the `webpack-dev-server` will use a self-signed certificate,
so your web browser will display a warning/exception upon accessing the page. If you get
`https://localhost:3035/sockjs-node/info?t=1503127986584 net::ERR_INSECURE_RESPONSE`
in your console, simply open the link in your browser and accept the SSL exception.
Now if you refresh your Rails view everything should work as expected.


## HOT module replacement

Webpacker out-of-the-box supports HMR with `webpack-dev-server` and
you can toggle it by setting `dev_server/hmr` option inside `webpacker.yml`.

Checkout this guide for more information:

- https://webpack.js.org/configuration/dev-server/#devserver-hot

To support HMR with React you would need to add `react-hot-loader`. Checkout this guide for
more information:

- https://gaearon.github.io/react-hot-loader/getstarted/

**Note:** Don't forget to disable `HMR` if you are not running `webpack-dev-server`
otherwise you will get not found error for stylesheets.


## Nginx

If you use Nginx in development to proxy requests to your Rails server from
another domain, like `myapp.dev`, the Webpacker middleware will be able to
forward requests for "packs" to the webpack dev server.

If you're using `inline` mode behing Nginx, you may also need to provide the
hostname to webpack dev server so it can initiate the websocket connection for
live reloading ([Webpack
docs](https://webpack.js.org/configuration/dev-server/#devserver-public)).

To do so, set the `public` option in `config/webpacker.yml`:

```yaml
development:
  # ...
  dev_server:
    # ...
    public: myapp.dev
```

You may also need to add the following location block to your local Nginx server
configuration for your Rails app.

```
server {
    listen 80;
    server_name myapp.dev

    # Proxy webpack dev server websocket requests
    location /sockjs-node {
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_pass http://127.0.0.1:3035; # change to match your webpack-dev-server host
    }

    # ...
}
```

## Customizing Logging

By default, the dev server will display a colored progress notification while
your code is being compiled.  (Under the hood, we are using `webpack-dev-server
--progress --color`).  However, this might cause issues if you don't use
`foreman` and/or try to log webpack-dev-server's output to a file.  You can
disable this stylized output by adding `pretty: false` to your `dev_server`
config:

```yaml
development:
  # ...
  dev_server:
    # ...
    pretty: false
```
