# Webpacker

![travis-ci status](https://api.travis-ci.org/rails/webpacker.svg?branch=master)
[![node.js](https://img.shields.io/badge/node-%3E%3D%206.0.0-brightgreen.svg)](https://nodejs.org/en/)
[![Gem](https://img.shields.io/gem/v/webpacker.svg)](https://github.com/rails/webpacker)

Webpacker makes it easy to use the JavaScript pre-processor and bundler
[webpack 3.x.x+](https://webpack.js.org/)
to manage application-like JavaScript in Rails. It coexists with the asset pipeline,
as the primary purpose for webpack is app-like JavaScript, not images, CSS, or
even JavaScript Sprinkles (that all continues to live in app/assets).

However, it is possible to use Webpacker for CSS, images and fonts assets as well,
in which case you may not even need the asset pipeline. This is mostly relevant when exclusively using component-based JavaScript frameworks.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Table of Contents

- [Prerequisites](#prerequisites)
- [Features](#features)
- [Installation](#installation)
  - [Usage](#usage)
  - [Development](#development)
  - [Webpack Configuration](#webpack-configuration)
  - [Custom Rails environments](#custom-rails-environments)
  - [Upgrading](#upgrading)
  - [Yarn Integrity](#yarn-integrity)
- [Integrations](#integrations)
  - [React](#react)
  - [Angular with TypeScript](#angular-with-typescript)
  - [Vue](#vue)
  - [Elm](#elm)
  - [Stimulus](#stimulus)
  - [Coffeescript](#coffeescript)
  - [Erb](#erb)
- [Paths](#paths)
  - [Resolved](#resolved)
  - [Watched](#watched)
- [Deployment](#deployment)
- [Docs](#docs)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Prerequisites

* Ruby 2.2+
* Rails 4.2+
* Node.js 6.0.0+
* Yarn 0.25.2+


## Features

* [webpack 3.x.x](https://webpack.js.org/)
* ES6 with [babel](https://babeljs.io/)
* Automatic code splitting using multiple entry points
* Stylesheets - Sass and CSS
* Images and fonts
* PostCSS - Auto-Prefixer
* Asset compression, source-maps, and minification
* CDN support
* React, Angular, Elm and Vue support out-of-the-box
* Rails view helpers
* Extensible and configurable


## Installation

You can either add Webpacker during setup of a new Rails 5.1+ application
using new `--webpack` option:

```bash
# Available Rails 5.1+
rails new myapp --webpack
```

Or add it to your `Gemfile`:

```ruby
# Gemfile
gem 'webpacker', '~> 3.3'

# OR if you prefer to use master
gem 'webpacker', git: 'https://github.com/rails/webpacker.git'
```

Finally, run following to install Webpacker:

```bash
bundle
bundle exec rails webpacker:install

# OR (on rails version < 5.0)
bundle exec rake webpacker:install
```


### Usage

Once installed, you can start writing modern ES6-flavored JavaScript apps right away:

```yml
app/javascript:
  ├── packs:
  │   # only webpack entry files here
  │   └── application.js
  └── src:
  │   └── application.css
  └── images:
      └── logo.svg
```

You can then link the JavaScript pack in Rails views using the `javascript_pack_tag` helper.
If you have styles imported in your pack file, you can link them by using `stylesheet_pack_tag`:

```erb
<%= javascript_pack_tag 'application' %>
<%= stylesheet_pack_tag 'application' %>
```

If you want to link a static asset for `<link rel="prefetch">` or `<img />` tag, you
can use the `asset_pack_path` helper:

```erb
<link rel="prefetch" href="<%= asset_pack_path 'application.css' %>" />
<img src="<%= asset_pack_path 'images/logo.svg' %>" />
```

**Note:** In order for your styles or static assets files to be available in your view,
you would need to link them in your "pack" or entry file.


### Development

Webpacker ships with two binstubs: `./bin/webpack` and `./bin/webpack-dev-server`.
Both are thin wrappers around the standard `webpack.js` and `webpack-dev-server.js`
executables to ensure that the right configuration files and environmental variables
are loaded based on your environment.

In development, Webpacker compiles on demand rather than upfront by default. This
happens when you refer to any of the pack assets using the Webpacker helper methods.
This means that you don't have to run any separate processes. Compilation errors are logged
to the standard Rails log.

If you want to use live code reloading, or you have enough JavaScript that on-demand compilation is too slow, you'll need to run `./bin/webpack-dev-server` or `ruby ./bin/webpack-dev-server`. Windows users will need to run these commands
in a terminal separate from `bundle exec rails s`. This process will watch for changes
in the `app/javascript/packs/*.js` files and automatically reload the browser to match.

```bash
# webpack dev server
./bin/webpack-dev-server

# watcher
./bin/webpack --colors --progress

# standalone build
./bin/webpack
```

Once you start this development server, Webpacker will automatically start proxying all
webpack asset requests to this server. When you stop the server, it'll revert back to
on-demand compilation.

You can use environment variables as options supported by
[webpack-dev-server](https://webpack.js.org/configuration/dev-server/) in the
form `WEBPACKER_DEV_SERVER_<OPTION>`. Please note that these environmental
variables will always take precedence over the ones already set in the
configuration file, and that the _same_ environmental variables must
be available to the `rails server` process.

```bash
WEBPACKER_DEV_SERVER_HOST=example.com WEBPACKER_DEV_SERVER_INLINE=true WEBPACKER_DEV_SERVER_HOT=false ./bin/webpack-dev-server
```

By default, the webpack dev server listens on `localhost` in development for security purposes.
However, if you want your app to be available over local LAN IP or a VM instance like vagrant,
you can set the `host` when running `./bin/webpack-dev-server` binstub:

```bash
WEBPACKER_DEV_SERVER_HOST=0.0.0.0 ./bin/webpack-dev-server
```

**Note:** You need to allow webpack-dev-server host as an allowed origin for `connect-src` if you are running your application in a restrict CSP environment (like Rails 5.2+). This can be done in Rails 5.2+ in the CSP initializer `config/initializers/content_security_policy.rb` with a snippet like this:

```ruby
  p.connect_src :self, :https, 'http://localhost:3035', 'ws://localhost:3035' if Rails.env.development?
```

**Note:** Don't forget to prefix `ruby` when running these binstubs on Windows

### Webpack Configuration

See [docs/webpack](docs/webpack.md) for modifying webpack configuration and loaders.


### Custom Rails environments

Out of the box Webpacker ships with - development, test and production environments in `config/webpacker.yml` however, in most production apps extra environments are needed as part of deployment workflow. Webpacker supports this out of the box from version 3.4.0+ onwards.

You can choose to define additional environment configurations in webpacker.yml,

```yml
staging:
  <<: *default

  # Production depends on precompilation of packs prior to booting for performance.
  compile: false

  # Cache manifest.json for performance
  cache_manifest: true

  # Compile staging packs to a separate directory
  public_output_path: packs-staging
```

or, Webpacker will use production environment as a fallback environment for loading configurations. Please note, `NODE_ENV` can either be set to `production` or `development`.
This means you don't need to create additional environment files inside `config/webpacker/*` and instead use webpacker.yml to load different configurations using `RAILS_ENV`.

For example, the below command will compile assets in production mode but will use staging configurations from `config/webpacker.yml` if available or use fallback production environment configuration:

```bash
RAILS_ENV=staging bundle exec rails assets:precompile
```

And, this will compile in development mode and load configuration for cucumber environment
if defined in webpacker.yml or fallback to production configuration

```bash
RAILS_ENV=cucumber NODE_ENV=development bundle exec rails assets:precompile
```

Please note, binstubs compiles in development mode however rake tasks
compiles in production mode.

```bash
# Compiles in development mode unless NODE_ENV is specified
./bin/webpack
./bin/webpack-dev-server

# compiles in production mode by default unless NODE_ENV is specified
bundle exec rails assets:precompile
bundle exec rails webpacker:compile
```


### Upgrading

You can run following commands to upgrade Webpacker to the latest stable version. This process involves upgrading the gem and related npm modules:

```bash
bundle update webpacker
yarn upgrade @rails/webpacker --latest
yarn add webpack-dev-server@^2.11.1
```

### Yarn Integrity

By default, in development, webpacker runs a yarn integrity check to ensure that all local npm packages are up-to-date. This is similar to what bundler does currently in Rails, but for JavaScript packages. If your system is out of date, then Rails will not initialize. You will be asked to upgrade your local npm packages by running `yarn install`.

To turn off this option, you will need to override the default by adding a new config option to your Rails development environment configuration file (`config/environment/development.rb`):

```
config.webpacker.check_yarn_integrity = false
```

You may also turn on this feature by adding the config option to any Rails environment configuration file:

```
config.webpacker.check_yarn_integrity = true
```

## Integrations

Webpacker ships with basic out-of-the-box integration for React, Angular, Vue and Elm.
You can see a list of available commands/tasks by running `bundle exec rails webpacker`:

### React

To use Webpacker with [React](https://facebook.github.io/react/), create a
new Rails 5.1+ app using `--webpack=react` option:

```bash
# Rails 5.1+
rails new myapp --webpack=react
```

(or run `bundle exec rails webpacker:install:react` in a existing Rails app already
setup with Webpacker).

The installer will add all relevant dependencies using Yarn, changes
to the configuration files, and an example React component to your
project in `app/javascript/packs` so that you can experiment with React right away.


### Angular with TypeScript

To use Webpacker with [Angular](https://angular.io/), create a
new Rails 5.1+ app using `--webpack=angular` option:

```bash
# Rails 5.1+
rails new myapp --webpack=angular
```

(or run `bundle exec rails webpacker:install:angular` on a Rails app already
setup with Webpacker).

The installer will add the TypeScript and Angular core libraries using Yarn alongside
a few changes to the configuration files. An example component written in
TypeScript will also be added to your project in `app/javascript` so that
you can experiment with Angular right away.

By default, Angular uses a JIT compiler for development environment. This
compiler is not compatible with restrictive CSP (Content Security
Policy) environments like Rails 5.2+. You can use Angular AOT compiler
in development with the [@ngtools/webpack](https://www.npmjs.com/package/@ngtools/webpack#usage) plugin.

Alternatively if you're using Rails 5.2+ you can enable `unsafe-eval` rule for your
development environment. This can be done in the `config/initializers/content_security_policy.rb`
with the following code:

```ruby
  if Rails.env.development?
    p.script_src :self, :https, :unsafe_eval
  else
    p.script_src :self, :https
  end
```


### Vue

To use Webpacker with [Vue](https://vuejs.org/), create a
new Rails 5.1+ app using `--webpack=vue` option:

```bash
# Rails 5.1+
rails new myapp --webpack=vue
```
(or run `bundle exec rails webpacker:install:vue` on a Rails app already setup with Webpacker).

The installer will add Vue and its required libraries using Yarn alongside
automatically applying changes needed to the configuration files. An example component will
be added to your project in `app/javascript` so that you can experiment with Vue right away.

If you're using Rails 5.2+ you'll need to enable `unsafe-eval` rule for your development environment.
This can be done in the `config/initializers/content_security_policy.rb` with the following
configuration:

```ruby
  if Rails.env.development?
    p.script_src :self, :https, :unsafe_eval
  else
    p.script_src :self, :https
  end
```
You can read more about this in the [Vue docs](https://vuejs.org/v2/guide/installation.html#CSP-environments).


### Elm

To use Webpacker with [Elm](http://elm-lang.org), create a
new Rails 5.1+ app using `--webpack=elm` option:

```
# Rails 5.1+
rails new myapp --webpack=elm
```

(or run `bundle exec rails webpacker:install:elm` on a Rails app already setup with Webpacker).

The Elm library and its core packages will be added via Yarn and Elm.
An example `Main.elm` app will also be added to your project in `app/javascript`
so that you can experiment with Elm right away.

### Stimulus

To use Webpacker with [Stimulus](http://stimulusjs.org), create a
new Rails 5.1+ app using `--webpack=stimulus` option:

```
# Rails 5.1+
rails new myapp --webpack=stimulus
```

(or run `bundle exec rails webpacker:install:stimulus` on a Rails app already setup with Webpacker).

Please read [The Stimulus Handbook](https://stimulusjs.org/handbook/introduction) or learn more about its source code at https://github.com/stimulusjs/stimulus

### Coffeescript

To add [Coffeescript](http://coffeescript.org/) support,
run `bundle exec rails webpacker:install:coffee` on a Rails app already
setup with Webpacker.

An example `hello_coffee.coffee` file will also be added to your project
in `app/javascript/packs` so that you can experiment with Coffeescript right away.

### Erb

To add [Erb](https://apidock.com/ruby/ERB) support in your JS templates,
run `bundle exec rails webpacker:install:erb` on a Rails app already
setup with Webpacker.

An example `hello_erb.js.erb` file will also be added to your project
in `app/javascript/packs` so that you can experiment with Erb-flavoured
javascript right away.


## Paths

By default, Webpacker ships with simple conventions for where the JavaScript
app files and compiled webpack bundles will go in your Rails app.
All these options are configurable from `config/webpacker.yml` file.

The configuration for what webpack is supposed to compile by default rests
on the convention that every file in `app/javascript/packs/*`**(default)**
or whatever path you set for `source_entry_path` in the `webpacker.yml` configuration
is turned into their own output files (or entry points, as webpack calls it). Therefore you don't want to put anything inside `packs` directory that you do not want to be
an entry file. As a rule of thumb, put all files you want to link in your views inside
"packs" directory and keep everything else under `app/javascript`.

Suppose you want to change the source directory from `app/javascript`
to `frontend` and output to `assets/packs`. This is how you would do it:

```yml
# config/webpacker.yml
source_path: frontend
source_entry_path: packs
public_output_path: assets/packs # outputs to => public/assets/packs
```

Similarly you can also control and configure `webpack-dev-server` settings from `config/webpacker.yml` file:

```yml
# config/webpacker.yml
development:
  dev_server:
    host: localhost
    port: 3035
```

If you have `hmr` turned to true, then the `stylesheet_pack_tag` generates no output, as you will want to configure your styles to be inlined in your JavaScript for hot reloading. During production and testing, the `stylesheet_pack_tag` will create the appropriate HTML tags.


### Resolved

If you are adding Webpacker to an existing app that has most of the assets inside
`app/assets` or inside an engine, and you want to share that
with webpack modules, you can use the `resolved_paths`
option available in `config/webpacker.yml`. This lets you
add additional paths that webpack should lookup when resolving modules:

```yml
resolved_paths: ['app/assets']
```

You can then import these items inside your modules like so:

```js
// Note it's relative to parent directory i.e. app/assets
import 'stylesheets/main'
import 'images/rails.png'
```

**Note:** Please be careful when adding paths here otherwise it
will make the compilation slow, consider adding specific paths instead of
whole parent directory if you just need to reference one or two modules


### Watched

By default, the lazy compilation is cached until a file is changed under your
tracked paths. You can configure which paths are tracked
by adding new paths to `watched_paths` array. This is much like Rails' `autoload_paths`:

```rb
# config/initializers/webpacker.rb
# or config/application.rb
Webpacker::Compiler.watched_paths << 'bower_components'
```


## Deployment

Webpacker hooks up a new `webpacker:compile` task to `assets:precompile`, which gets run whenever you run `assets:precompile`. If you are not using Sprockets, `webpacker:compile` is automatically aliased to `assets:precompile`. Remember to set NODE_ENV environment variable to production during deployment or when running this rake task.

## Docs

You can find more detailed guides under [docs](./docs).


## License
Webpacker is released under the [MIT License](https://opensource.org/licenses/MIT).
