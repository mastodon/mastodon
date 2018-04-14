**Please note that Webpacker 3.1.0 and 3.1.1 has some serious bugs so please consider using either 3.0.2 or 3.2.0**

## [3.4.3] - 2018-04-3

### Fixed
  - Lock webpacker version in installer [#1401](https://github.com/rails/webpacker/issues/1401)

## [3.4.1] - 2018-03-24

## Fixed
  - Yarn integrity check in development [#1374](https://github.com/rails/webpacker/issues/1374)


## [3.4.0] - 2018-03-23

**Please use 3.4.1 instead**

## Added
  - Support for custom Rails environments [#1359](https://github.com/rails/webpacker/pull/1359)

*This could break the compilation if you set NODE_ENV to custom environment. Now, NODE_ENV only understands production or development mode*


## [3.3.1] - 2018-03-12

## Fixed

- Use webpack dev server 2.x until webpacker supports webpack 4.x [#1338](https://github.com/rails/webpacker/issues/1338)

## [3.3.0] - 2018-03-03

### Added

- Separate task for installing/updating binstubs
- CSS modules support [#1248](https://github.com/rails/webpacker/pull/1248)
- Pass `relative_url_root` to webpacker config [#1236](https://github.com/rails/webpacker/pull/1236)

### Breaking changes

- Fixes #1281 by installing binstubs only as local executables. To upgrade:

```
bundle exec rails webpacker:binstubs
```
- set function is now removed from plugins and loaders, please use `append` or `prepend`

```js
// config/webpack/environment.js
const { environment } = require('@rails/webpacker')

environment.loaders.append('json', {
  test: /\.json$/,
  use: 'json-loader'
})
```

### Fixed
- Limit ts-loader to 3.5.0 until webpack 4 support [#1308](https://github.com/rails/webpacker/pull/1308)
- Custom env support [#1304](https://github.com/rails/webpacker/pull/1304)

## [3.2.2] - 2018-02-11

### Added

- Stimulus example [https://stimulusjs.org/](https://stimulusjs.org/)

```bash
bundle exec rails webpacker:install:stimulus
```

- Upgrade gems and npm packages [#1254](https://github.com/rails/webpacker/pull/1254)

And, bunch of bug fixes [See changes](https://github.com/rails/webpacker/compare/v3.2.1...v3.2.2)

## [3.2.1] - 2018-01-21

- Disable dev server running? check if no dev server config is present in that environment [#1179](https://github.com/rails/webpacker/pull/1179)

- Fix checking 'webpack' binstub on Windows [#1123](https://github.com/rails/webpacker/pull/1123)

- silence yarn output if checking is successfull [#1131](https://github.com/rails/webpacker/pull/1131)

- Update uglifyJs plugin to support ES6 [#1194](https://github.com/rails/webpacker/pull/1194)

- Add typescript installer [#1145](https://github.com/rails/webpacker/pull/1145)

- Update default extensions and move to installer [#1181](https://github.com/rails/webpacker/pull/1181)

- Revert file loader [#1196](https://github.com/rails/webpacker/pull/1196)


## [3.2.0] - 2017-12-16

### To upgrade:

```bash
bundle update webpacker
yarn upgrade @rails/webpacker
```

### Breaking changes

If you are using react, vue, angular, elm, erb or coffeescript inside your
`packs/` please re-run the integration installers as described in the README.

```bash
bundle exec rails webpacker:install:react
bundle exec rails webpacker:install:vue
bundle exec rails webpacker:install:angular
bundle exec rails webpacker:install:elm
bundle exec rails webpacker:install:erb
bundle exec rails webpacker:install:coffee
```

Or simply copy required loaders used in your app from
https://github.com/rails/webpacker/tree/master/lib/install/loaders
into your `config/webpack/loaders/`
directory and add it to webpack build from `config/webpack/environment.js`

```js
const erb =  require('./loaders/erb')
const elm =  require('./loaders/elm')
const typescript =  require('./loaders/typescript')
const vue =  require('./loaders/vue')
const coffee =  require('./loaders/coffee')

environment.loaders.append('coffee', coffee)
environment.loaders.append('vue', vue)
environment.loaders.append('typescript', typescript)
environment.loaders.append('elm', elm)
environment.loaders.append('erb', erb)
```

In `.postcssrc.yml` you need to change the plugin name from `postcss-smart-import` to `postcss-import`:

```yml
plugins:
  postcss-import: {}
  postcss-cssnext: {}
```

### Added (npm module)

- Upgrade gems and webpack dependencies

- `postcss-import` in place of `postcss-smart-import`


### Removed (npm module)

- `postcss-smart-import`, `coffee-loader`, `url-loader`, `rails-erb-loader` as dependencies

-  `publicPath` from file loader [#1107](https://github.com/rails/webpacker/pull/1107)


### Fixed (npm module)

- Return native array type for `ConfigList` [#1098](https://github.com/rails/webpacker/pull/1098)


### Added (Gem)

- New `asset_pack_url` helper [#1102](https://github.com/rails/webpacker/pull/1102)

- New installers for coffee and erb

```bash
bundle exec rails webpacker:install:erb
bundle exec rails webpacker:install:coffee
```

- Resolved paths from webpacker.yml to compiler watched list


## [3.1.1] - 2017-12-11

### Fixed

- Include default webpacker.yml config inside npm package


## [3.1.0] - 2017-12-11


### Added (npm module)

- Expose base config from environment

```js
environment.config.set('resolve.extensions', ['.foo', '.bar'])
environment.config.set('output.filename', '[name].js')
environment.config.delete('output.chunkFilename')
environment.config.get('resolve')
environment.config.merge({ output: {
    filename: '[name].js'
  }
})
```

- Expose new API's for loaders and plugins to insert at position

```js
const jsonLoader =  {
  test: /\.json$/,
  exclude: /node_modules/,
  loader: 'json-loader'
}

environment.loaders.append('json', jsonLoader)
environment.loaders.prepend('json', jsonLoader)
environment.loaders.insert('json', jsonLoader, { after: 'style' } )
environment.loaders.insert('json', jsonLoader, { before: 'babel' } )

// Update a plugin
const manifestPlugin = environment.plugins.get('Manifest')
manifestPlugin.opts.writeToFileEmit = false

// Update coffee loader to use coffeescript 2
const babelLoader = environment.loaders.get('babel')
environment.loaders.insert('coffee', {
  test: /\.coffee(\.erb)?$/,
  use:  babelLoader.use.concat(['coffee-loader'])
}, { before: 'json' })
```

- Expose `resolve.modules` paths like loaders and plugins

```js
environment.resolvedModules.append('vendor', 'vendor')
```

- Enable sourcemaps in `style` and `css` loader

- Separate `css` and `sass` loader for easier configuration. `style` loader is now
`css` loader, which resolves `.css` files and `sass` loader resolves `.scss` and `.sass`
files.

```js
// Enable css modules with sass loader
const sassLoader = environment.loaders.get('sass')
const cssLoader = sassLoader.use.find(loader => loader.loader === 'css-loader')

cssLoader.options = Object.assign({}, cssLoader.options, {
  modules: true,
  localIdentName: '[path][name]__[local]--[hash:base64:5]'
})
```

- Expose rest of configurable dev server options from webpacker.yml

```yml
quiet: false
headers:
  'Access-Control-Allow-Origin': '*'
watch_options:
  ignored: /node_modules/
```

- `pretty` option to disable/enable color and progress output when running dev server

```yml
dev_server:
  pretty: false
```

- Enforce deterministic loader order in desc order, starts processing from top to bottom

- Enforce the entire path of all required modules match the exact case of the actual path on disk using [case sensitive paths plugin](https://github.com/Urthen/case-sensitive-paths-webpack-plugin).

- Add url loader to process and embed smaller static files


### Removed

- resolve url loader [#1042](https://github.com/rails/webpacker/issues/1042)

### Added (Gem)

- Allow skipping webpacker compile using an env variable

```bash
WEBPACKER_PRECOMPILE=no|false|n|f
WEBPACKER_PRECOMPILE=false bundle exec rails assets:precompile
```

- Use `WEBPACKER_ASSET_HOST` instead of `ASSET_HOST` for CDN

- Alias `webpacker:compile` task to `assets:precompile` if is not defined so it works
without sprockets


## [3.0.2] - 2017-10-04

### Added

- Allow dev server connect timeout (in seconds) to be configurable, default: 0.01

```rb
# Change to 1s
Webpacker.dev_server.connect_timeout = 1
```

- Restrict the source maps generated in production [#770](https://github.com/rails/webpacker/pull/770)

- Binstubs [#833](https://github.com/rails/webpacker/pull/833)

- Allow dev server settings to be overriden by env variables [#843](https://github.com/rails/webpacker/pull/843)

- A new `lookup` method to manifest to perform lookup without raise and return `nil`

```rb
Webpacker.manifest.lookup('foo.js')
# => nil
Webpacker.manifest.lookup!('foo.js')
# => raises Webpacker::Manifest::MissingEntryError
```

- Catch all exceptions in `DevServer.running?` and return false [#878](https://github.com/rails/webpacker/pull/878)

### Removed

- Inline CLI args for dev server binstub, use env variables instead

- Coffeescript as core dependency. You have to manually add coffeescript now, if you are using
it in your app.

```bash
yarn add coffeescript@1.12.7

# OR coffeescript 2.0
yarn add coffeescript
```

## [3.0.1] - 2017-09-01

### Fixed

- Missing `node_modules/.bin/*` files by bumping minimum Yarn version to 0.25.2 [#727](https://github.com/rails/webpacker/pull/727)

- `webpacker:compile` task so that fails properly when webpack compilation fails [#728](https://github.com/rails/webpacker/pull/728)

- Rack dev server proxy middleware when served under another proxy (example: pow), which uses `HTTP_X_FORWARDED_HOST` header resulting in `404` for webpacker assets

- Make sure tagged logger works with rails < 5 [#716](https://github.com/rails/webpacker/pull/716)

### Added

- Allow webpack dev server listen host/ip to be configurable using additional `--listen-host` option

  ```bash
  ./bin/webpack-dev-server --listen-host 0.0.0.0 --host localhost
  ```

### Removed

- `watchContentBase` from devServer config so it doesn't unncessarily trigger
live reload when manifest changes. If you have applied this workaround from [#724](https://github.com/rails/webpacker/issues/724), please revert the change from `config/webpack/development.js` since this is now fixed.


## [3.0.0] - 2017-08-30

### Added

- `resolved_paths` option to allow adding additional paths webpack should lookup when resolving modules

```yml
  # config/webpacker.yml
  # Additional paths webpack should lookup modules
  resolved_paths: [] # empty by default
```

- `Webpacker::Compiler.fresh?` and `Webpacker::Compiler.stale?` answer the question of whether compilation is needed.
  The old `Webpacker::Compiler.compile?` predicate is deprecated.

- Dev server config class that exposes config options through singleton.

  ```rb
  Webpacker.dev_server.running?
  ```

- Rack middleware proxies webpacker requests to dev server so we can always serve from same-origin and the lookup works out of the box - no more paths prefixing

- `env` attribute on `Webpacker::Compiler` allows setting custom environment variables that the compilation is being run with

  ```rb
  Webpacker::Compiler.env['FRONTEND_API_KEY'] = 'your_secret_key'
  ```

### Breaking changes

**Note:** requires running `bundle exec rails webpacker:install`

`config/webpack/**/*.js`:

- The majority of this config moved to the [@rails/webpacker npm package](https://www.npmjs.com/package/@rails/webpacker). `webpacker:install` only creates `config/webpack/{environment,development,test,production}.js` now so if you're upgrading from a previous version you can remove all other files.

`webpacker.yml`:

- Move dev-server config options under defaults so it's transparently available in all environments

- Add new `HMR` option for hot-module-replacement

- Add HTTPS

### Removed

- Host info from manifest.json, now looks like this:

  ```json
  {
    "hello_react.js": "/packs/hello_react.js"
  }
  ```

### Fixed

- Update `webpack-dev-server.tt` to respect RAILS_ENV and NODE_ENV values [#502](https://github.com/rails/webpacker/issues/502)
- Use `0.0.0.0` as default listen address for `webpack-dev-server`
- Serve assets using `localhost` from dev server - [#424](https://github.com/rails/webpacker/issues/424)

```yml
  dev_server:
    host: localhost
```

- On Windows, `ruby bin/webpacker` and `ruby bin/webpacker-dev-server` will now bypass yarn, and execute via `node_modules/.bin` directly - [#584](https://github.com/rails/webpacker/pull/584)

### Breaking changes

- Add `compile` and `cache_path` options to `config/webpacker.yml` for configuring lazy compilation of packs when a file under tracked paths is changed [#503](https://github.com/rails/webpacker/pull/503). To enable expected behavior, update `config/webpacker.yml`:

  ```yaml
    default: &default
      cache_path: tmp/cache/webpacker
    test:
      compile: true

    development:
      compile: true

    production:
      compile: false
  ```

- Make test compilation cacheable and configurable so that the lazy compilation
only triggers if files are changed under tracked paths.
Following paths are watched by default -

  ```rb
    ["app/javascript/**/*", "yarn.lock", "package.json", "config/webpack/**/*"]
  ```

  To add more paths:

  ```rb
  # config/initializers/webpacker.rb or config/application.rb
  Webpacker::Compiler.watched_paths << 'bower_components'
  ```

## [2.0] - 2017-05-24

### Fixed
- Update `.babelrc` to fix compilation issues - [#306](https://github.com/rails/webpacker/issues/306)

- Duplicated asset hosts - [#320](https://github.com/rails/webpacker/issues/320), [#397](https://github.com/rails/webpacker/pull/397)

- Missing asset host when defined as a `Proc` or on `ActionController::Base.asset_host` directly - [#397](https://github.com/rails/webpacker/pull/397)

- Incorrect asset host when running `webpacker:compile` or `bin/webpack` in development mode - [#397](https://github.com/rails/webpacker/pull/397)

- Update `webpacker:compile` task to use `stdout` and `stderr` for better logging - [#395](https://github.com/rails/webpacker/issues/395)

- ARGV support for `webpack-dev-server` - [#286](https://github.com/rails/webpacker/issues/286)


### Added
- [Elm](http://elm-lang.org) support. You can now add Elm support via the following methods:
  - New app: `rails new <app> --webpack=elm`
  - Within an existing app: `rails webpacker:install:elm`

- Support for custom `public_output_path` paths independent of `source_entry_path` in `config/webpacker.yml`. `output` is also now relative to `public/`. - [#397](https://github.com/rails/webpacker/pull/397)

    Before (compile to `public/packs`):
    ```yaml
      source_entry_path: packs
      public_output_path: packs
    ```
    After (compile to `public/sweet/js`):
    ```yaml
      source_entry_path: packs
      public_output_path: sweet/js
    ```

- `https` option to use `https` mode, particularly on platforms like - https://community.c9.io/t/running-a-rails-app/1615 or locally - [#176](https://github.com/rails/webpacker/issues/176)

- [Babel] Dynamic import() and Class Fields and Static Properties babel plugin to `.babelrc`

```json
{
  "presets": [
    ["env", {
      "modules": false,
      "targets": {
        "browsers": "> 1%",
        "uglify": true
      },
      "useBuiltIns": true
    }]
  ],

  "plugins": [
    "syntax-dynamic-import",
    "transform-class-properties", { "spec": true }
  ]
}
```

- Source-map support for production bundle


#### Breaking Change

- Consolidate and flatten `paths.yml` and `development.server.yml` config into one file - `config/webpacker.yml` - [#403](https://github.com/rails/webpacker/pull/403). This is a breaking change and requires you to re-install webpacker and cleanup old configuration files.

  ```bash
  bundle update webpacker
  bundle exec rails webpacker:install

  # Remove old/unused configuration files
  rm config/webpack/paths.yml
  rm config/webpack/development.server.yml
  rm config/webpack/development.server.js
  ```

  __Warning__: For now you also have to add a pattern in `.gitignore` by hand.
  ```diff
   /public/packs
  +/public/packs-test
   /node_modules
   ```

## [1.2] - 2017-04-27
Some of the changes made requires you to run below commands to install new changes.

```
bundle update webpacker
bundle exec rails webpacker:install
```


### Fixed
- Support Spring - [#205](https://github.com/rails/webpacker/issues/205)

  ```ruby
  Spring.after_fork { Webpacker.bootstrap } if defined?(Spring)
  ```
- Check node version and yarn before installing webpacker - [#217](https://github.com/rails/webpacker/issues/217)

- Include webpacker helper to views - [#172](https://github.com/rails/webpacker/issues/172)

- Webpacker installer on windows - [#245](https://github.com/rails/webpacker/issues/245)

- Yarn duplication - [#278](https://github.com/rails/webpacker/issues/278)

- Add back Spring for `rails-erb-loader` - [#216](https://github.com/rails/webpacker/issues/216)

- Move babel presets and plugins to .babelrc - [#202](https://github.com/rails/webpacker/issues/202)


### Added
- A changelog - [#211](https://github.com/rails/webpacker/issues/211)
- Minimize CSS assets - [#218](https://github.com/rails/webpacker/issues/218)
- Pack namespacing support - [#201](https://github.com/rails/webpacker/pull/201)

  For example:
  ```
  app/javascript/packs/admin/hello_vue.js
  app/javascript/packs/admin/hello.vue
  app/javascript/packs/hello_vue.js
  app/javascript/packs/hello.vue
  ```
- Add tree-shaking support - [#250](https://github.com/rails/webpacker/pull/250)
- Add initial test case by @kimquy [#259](https://github.com/rails/webpacker/pull/259)
- Compile assets before test:controllers and test:system


### Removed
- Webpack watcher - [#295](https://github.com/rails/webpacker/pull/295)


## [1.1] - 2017-03-24

This release requires you to run below commands to install new features.

```
bundle update webpacker
bundle exec rails webpacker:install

# if installed react, vue or angular
bundle exec rails webpacker:install:[react, angular, vue]
```

### Added (breaking changes)
- Static assets support - [#153](https://github.com/rails/webpacker/pull/153)
- Advanced webpack configuration - [#153](https://github.com/rails/webpacker/pull/153)


### Removed

```rb
config.x.webpacker[:digesting] = true
```
