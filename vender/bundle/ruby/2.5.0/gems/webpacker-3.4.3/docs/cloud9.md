# Webpack dev server and Rails on Cloud9

**Please note that this article is particularly relevant when
migrating the [`webpacker`] gem from v3.0.1 to v3.0.2, as described in
the [below](#binstub-versions).**

[**`[Go to tl;dr]`**](#tldr)

## Contents

  - [Context](#context)
  - [Binstub versions](#binstub-versions)
  - [Quick solution](#quick-solution)
  - [Flexible solution](#flexible-solution)
  - [Sources](#sources)
  - [Versions](#versions)
  - [tl;dr](#tldr)

## Context

This article describes how to properly configure
[`webpack-dev-server`] with [`webpacker`] gem on a [Cloud9] workspace.
After a preliminary remark about the proper binstub version of the
`./bin/webpack-dev-server` script, this article presents two ways to
tackle the task: a simple and [quick solution](#quick-solution), which
is sufficient if we work alone on a project, and a slightly more
involved but [flexible approach](#flexible-solution), that can be
useful when several people might work in the same codebase.

[Cloud9]: https://c9.io
[`webpack-dev-server`]: https://github.com/webpack/webpack-dev-server
[`webpacker`]: https://github.com/rails/webpacker

## Binstub versions

A lot of the confusion about the [`webpack-dev-server`] options and
why they might not be properly taken into account, might be due to an
outdated version of the `./bin/webpack-dev-server` script. The script
created by the `rails webpacker:install` task of the [`webpacker`] gem
v3.0.1 ([source][v3.0.1/lib/install/bin/webpack-dev-server.tt]) is not
compatible with how v3.0.2 (sic) of the gem handles the
[`webpack-dev-server`] option flags (see full list of
[versions](#versions) below), which logically expects the
corresponding [binstub version][#833] of the script
([source][v3.0.2/exe/webpack-dev-server]). So please make sure that
you are using the [correct binstub][v3.0.2/exe/webpack-dev-server]
(the same applies to [`./bin/webpack`][v3.0.2/exe/webpack]). To be
fair, the [changelog of v3.0.2] properly mentions the change:

> - Added: Binstubs [#833]
> - (...)
> - Removed: Inline CLI args for dev server binstub, use env variables
  instead

[changelog of v3.0.2]: https://github.com/rails/webpacker/blob/v3.0.2/CHANGELOG.md#302---2017-10-04
[v3.0.1/lib/install/bin/webpack-dev-server.tt]: https://github.com/rails/webpacker/blob/v3.0.1/lib/install/bin/webpack-dev-server.tt
[v3.0.2/exe/webpack-dev-server]: https://github.com/rails/webpacker/blob/v3.0.2/exe/webpack-dev-server
[v3.0.2/exe/webpack]: https://github.com/rails/webpacker/blob/v3.0.2/exe/webpack
[#833]: https://github.com/rails/webpacker/pull/833/files

## Quick solution

If you are working alone, the easiest way to fix the configuration of
the [`webpack-dev-server`] is to modify the `development.dev_server`
entry of the `config/webpacker.yml` file.

### `config/webpacker.yml` file

The `development.dev_server` entry of the `config/webpacker.yml` file
has to be changed from the following default values:

```yaml
dev_server:
  https: false
  host: localhost
  port: 3035
  public: localhost:3035
  hmr: false
  # Inline should be set to true if using HMR
  inline: true
  overlay: true
  disable_host_check: true
  use_local_ip: false
```

into the these custom configuration:

```yaml
dev_server:
  https: true
  host: localhost
  port: 8082
  public: your-workspace-name-yourusername.c9users.io:8082
  hmr: false
  inline: false
  overlay: true
  disable_host_check: true
  use_local_ip: false
```

You can obtain the value `your-workspace-name-yourusername.c9users.io`
for your [Cloud9] workspace with `echo ${C9_HOSTNAME}`.

There are four main differences with the approaches found in the
mentioned [sources](#sources):

- Some solutions suggested to set the [`host`][devserver-host] option
  to `your-workspace-name-yourusername.c9users.io`, which required to
  add a line to the `/etc/hosts` file by running `echo "0.0.0.0
  ${C9_HOSTNAME}" | sudo tee -a /etc/hosts`. This was only necessary
  due to restrictions in previous versions of [`webpacker`] and how
  the value of the [`public`][devserver-public] setting was
  calculated. Currently it is [no longer necessary][pr-comment-hosts]
  to modify the `/etc/hosts` file because the [`host`][devserver-host]
  setting can be kept as `localhost`.

[pr-comment-hosts]: https://github.com/rails/webpacker/pull/1033#pullrequestreview-78992024

- Some solutions stressed the need to set the
  [`https`][devserver-https] option to `false` but this failed with
  `net::ERR_ABORTED` in the browser console and raised the following
  exception in the server when the client tried to get the
  JavaScript sources:

  ```
  #<OpenSSL::SSL::SSLError: SSL_connect SYSCALL returned=5 errno=0 state=unknown state>
  ```

  Setting `https: true` removes the issue.

- By leaving the [`inline`][devserver-inline] option to the default
  `false` value, the live compilation still works but the browser
  console constantly reports the following error:

  ```
  Failed to load https://your-workspace-name-yourusername.c9users.io:8082/sockjs-node/info?t=1511016561187: No 'Access-Control-Allow-Origin' header is present on the requested resource.
  Origin 'https://your-workspace-name-yourusername.c9users.io' is therefore not allowed access. The response had HTTP status code 503.
  ```

  Setting `inline: false` removes the issue.


- None of the solutions suggested to set the
  [`public`][devserver-public] option in the `config/webpacker.yml`
  file and some suggested to pass it to the `webpack-dev-server`
  command line. By setting it in the configuration file we don't need
  to care about it in the terminal.

[devserver-host]: https://webpack.js.org/configuration/dev-server/#devserver-host
[devserver-https]: https://webpack.js.org/configuration/dev-server/#devserver-https
[devserver-inline]: https://webpack.js.org/configuration/dev-server/#devserver-inline
[devserver-public]: https://webpack.js.org/configuration/dev-server/#devserver-public

With this configuration, running as usual `./bin/webpack-dev-server`
in one terminal and `./bin/rails s -b $IP -p $PORT` in another should
work.

## Flexible solution

The previous solution is useful and fast to implement, but if you are
working with other people on the same repo it can be tricky to
maintain the proper configuration in the `config/webpacker.yml` file.
Moreover, the hostname of your [Cloud9] workspace is hardcoded, so
that the configuration is not portable.

A hint about another way to configure the `webpack-dev-server` can be
found in the [README of this repo][`webpacker` documentation]:

> You can use environment variables as options supported by
> webpack-dev-server in the form `WEBPACKER_DEV_SERVER_<OPTION>`.
> Please note that these environment variables will always take
> precedence over the ones already set in the configuration file.

Note that when the configuration of the [`webpack-dev-server`] is
tweaked with ENV variables, those same values _have to be passed_ to
the `rails server` process as well in order to let it use the _same_
configuration.

Taking that into account, a flexible solution can be implemented using
[`foreman`] with the following `Procfile.dev`:

[`foreman`]: https://github.com/ddollar/foreman

```Procfile
web:        ./bin/rails server -b ${RAILS_SERVER_BINDING:-localhost} -p ${RAILS_SERVER_PORT:-3000}
webpacker:  ./bin/webpack-dev-server
```

and this `bin/start` script:

```bash
#!/bin/bash

# Immediately exit script on first error
set -e -o pipefail

APP_ROOT_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "${APP_ROOT_FOLDER}"

if [ -n "${C9_USER}" ]; then
  # We are in a Cloud9 machine

  # Make sure that Postgres is running
  sudo service postgresql status || sudo service postgresql start

  # Adapt the configuration of the webpack-dev-server
  export APP_DOMAIN="${C9_HOSTNAME}"
  export RAILS_SERVER_BINDING='0.0.0.0'
  export RAILS_SERVER_PORT='8080'
  export WEBPACKER_DEV_SERVER_PORT='8082'
  export WEBPACKER_DEV_SERVER_HTTPS='true'
  export WEBPACKER_DEV_SERVER_HOST="localhost"
  export WEBPACKER_DEV_SERVER_PUBLIC="${C9_HOSTNAME}:${WEBPACKER_DEV_SERVER_PORT}"
  export WEBPACKER_DEV_SERVER_HMR='false'
  export WEBPACKER_DEV_SERVER_INLINE='false'
  export WEBPACKER_DEV_SERVER_OVERLAY='true'
  export WEBPACKER_DEV_SERVER_DISABLE_HOST_CHECK='true'
  export WEBPACKER_DEV_SERVER_USE_LOCAL_IP='false'
fi

foreman start -f Procfile.dev
```

With these two scripts in place, the application can always be started
by running `bin/start`, in both [Cloud9] and other systems. The
trick is that by exporting the `WEBPACKER_DEV_SERVER_*` variables
before calling `foreman start`, we make sure that those values are
available to both `webpack-dev-server` and `rails server` processes.

## Sources

- ["Webpack dev server and Rails on Cloud9"][original-article] (the
  original source for the present article, inspired by this
  [comment][original-comment])
- ["Making Webpacker run on Cloud 9"] (GitHub issue)
- ["Anyone here got webpack-dev-server to work on Cloud 9?"] (GitHub issue)
- [`webpacker` documentation]
- [`webpacker/dev_server.rb` code]
- [`webpack-dev-server` documentation]
- ["Using Rails With Webpack in Cloud 9"] (blog article)

[original-article]: http://rbf.io/en/blog/2017/11/18/webpack-dev-server-and-rails-on-cloud9/
[original-comment]: https://github.com/rails/webpacker/issues/176#issuecomment-345532309
["Making Webpacker run on Cloud 9"]: https://github.com/rails/webpacker/issues/176
["Anyone here got webpack-dev-server to work on Cloud 9?"]: https://github.com/webpack/webpack-dev-server/issues/230
[`webpacker` documentation]: https://github.com/rails/webpacker/tree/v3.0.2#development
[`webpacker/dev_server.rb` code]: https://github.com/rails/webpacker/blob/v3.0.2/lib/webpacker/dev_server.rb#L55
[`webpack-dev-server` documentation]: https://webpack.js.org/configuration/dev-server/
["Using Rails With Webpack in Cloud 9"]: http://aalvarez.me/blog/posts/using-rails-with-webpack-in-cloud-9.html

## Versions

Since things in this ecosystem move fast, it's important to mention the
versions of the world for which this documentation is relevant:

```shell
$ egrep '^    ?(ruby|webpacker|rails) ' Gemfile.lock
    rails (5.1.4)
    webpacker (3.0.2)
  ruby 2.4.2p198

$ yarn versions
yarn versions v1.1.0
{ http_parser: '2.7.0',
  node: '8.5.0',
  v8: '6.0.287.53',
  uv: '1.14.1',
  zlib: '1.2.11',
  ares: '1.10.1-DEV',
  modules: '57',
  nghttp2: '1.25.0',
  openssl: '1.0.2l',
  icu: '59.1',
  unicode: '9.0',
  cldr: '31.0.1',
  tz: '2017b' }

$ cat /etc/os-release | head -6
NAME="Ubuntu"
VERSION="14.04.5 LTS, Trusty Tahr"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 14.04.5 LTS"
VERSION_ID="14.04"
```

Everything was tested using Chrome Version 62.

## tl;dr

1. Make sure that you are running the [proper binstub
   version](#binstub-versions) of `./bin/webpack-dev-server`.

1. Change the `development.dev_server` entry `config/webpacker.yml` file into:

    ```yaml
    dev_server:
      https: true
      host: localhost
      port: 8082
      public: your-workspace-name-yourusername.c9users.io:8082
      hmr: false
      inline: false
      overlay: true
      disable_host_check: true
      use_local_ip: false
    ```

1. Now running as usual `./bin/webpack-dev-server` in one terminal and
   `./bin/rails s -b $IP -p $PORT` in another should work as expected.
