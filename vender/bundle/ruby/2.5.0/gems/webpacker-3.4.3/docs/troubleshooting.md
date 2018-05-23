# Troubleshooting


## ENOENT: no such file or directory - node-sass

*  If you get this error `ENOENT: no such file or directory - node-sass` on Heroku
or elsewhere during `assets:precompile` or `bundle exec rails webpacker:compile`
then you would need to rebuild node-sass. It's a bit of a weird error;
basically, it can't find the `node-sass` binary.
An easy solution is to create a postinstall hook - `npm rebuild node-sass` in
`package.json` and that will ensure `node-sass` is rebuilt whenever
you install any new modules.


## Can't find hello_react.js in manifest.json

* If you get this error `Can't find hello_react.js in manifest.json`
when loading a view in the browser it's because webpack is still compiling packs.
Webpacker uses a `manifest.json` file to keep track of packs in all environments,
however since this file is generated after packs are compiled by webpack. So,
if you load a view in browser whilst webpack is compiling you will get this error.
Therefore, make sure webpack
(i.e `./bin/webpack-dev-server`) is running and has
completed the compilation successfully before loading a view.


## throw er; // Unhandled 'error' event

* If you get this error while trying to use Elm, try rebuilding Elm. You can do
  so with a postinstall hook in your `package.json`:

```
"scripts": {
  "postinstall": "npm rebuild elm"
}
```


## webpack or webpack-dev-server not found

* This could happen if  `webpacker:install` step is skipped. Please run `bundle exec rails webpacker:install` to fix the issue.

* If you encounter the above error on heroku after upgrading from Rails 4.x to 5.1.x, then the problem might be related to missing `yarn` binstub. Please run following commands to update/add binstubs:

```bash
bundle config --delete bin
./bin/rails app:update:bin # or rails app:update:bin
```


## Running webpack on Windows

If you are running webpack on Windows, your command shell may not be able to interpret the preferred interpreter
for the scripts generated in `bin/webpack` and `bin/webpack-dev-server`. Instead you'll want to run the scripts
manually with Ruby:

```
C:\path>ruby bin\webpack
C:\path>ruby bin\webpack-dev-server
```


## Invalid configuration object. webpack has been initialised using a configuration object that does not match the API schema.

If you receive this error when running `$ ./bin/webpack-dev-server` ensure your configuration is correct; most likely the path to your "packs" folder is incorrect if you modified from the original "source_path" defined in `config/webpacker.yml`.

## Running Elm on Continuous Integration (CI) services such as CircleCI, CodeShip, Travis CI

If your tests are timing out or erroring on CI it is likely that you are experiencing the slow Elm compilation issue described here: [elm-compiler issue #1473](https://github.com/elm-lang/elm-compiler/issues/1473)

The issue is related to CPU count exposed by the underlying service. The basic solution involves using [libsysconfcpus](https://github.com/obmarg/libsysconfcpus) to change the reported CPU count.

Basic fix involves:

```bash
# install sysconfcpus on CI
git clone https://github.com/obmarg/libsysconfcpus.git $HOME/dependencies/libsysconfcpus
cd libsysconfcpus
.configure --prefix=$HOME/dependencies/sysconfcpus
make && make install

# use sysconfcpus with elm-make
mv $HOME/your_rails_app/node_modules/.bin/elm-make $HOME/your_rails_app/node_modules/.bin/elm-make-old
printf "#\041/bin/bash\n\necho \"Running elm-make with sysconfcpus -n 2\"\n\n$HOME/dependencies/sysconfcpus/bin/sysconfcpus -n 2 $HOME/your_rails_app/node_modules/.bin/elm-make-old \"\$@\"" > $HOME/your_rails_app/node_modules/.bin/elm-make
chmod +x $HOME/your_rails_app/node_modules/.bin/elm-make
```

## Rake assets:precompile fails. ExecJS::RuntimeError
This error occurs because you are trying to uglify a pack that's already been minified by Webpacker. To avoid this conflict and prevent appearing of ExecJS::RuntimeError error, you will need to disable uglifier from Rails config:

```ruby
// production.rb
# From

Rails.application.config.assets.js_compressor = :uglifier

# To

#Rails.application.config.assets.js_compressor = :uglifier

```

### Angular: WARNING in ./node_modules/@angular/core/esm5/core.js, Critical dependency: the request of a dependency is an expression

To silent these warnings, please update `config/webpack/environment.js`

```js
// environment.js
const webpack = require('webpack')
const { resolve } = require('path')
const { environment, config } = require('@rails/webpacker')

environment.plugins.append('ContextReplacement',
  new webpack.ContextReplacementPlugin(
    /angular(\\|\/)core(\\|\/)(@angular|esm5)/,
    resolve(config.source_path)
  )
)
```
