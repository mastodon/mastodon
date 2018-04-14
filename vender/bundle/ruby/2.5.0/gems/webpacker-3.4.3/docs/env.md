# Environment variables


Environment variables are supported out of the box in Webpacker. For example if
you run the webpack dev server like so:
```
FOO=hello BAR=world ./bin/webpack-dev-server
```

You can then reference these variables in your JavaScript app code with
`process.env`:

```js
console.log(process.env.FOO) // Compiles to console.log("hello")
```

You may want to store configuration in environment variables via `.env` files,
similar to the [dotenv Ruby gem](https://github.com/bkeepers/dotenv).

In development, if you use [Foreman](http://ddollar.github.io/foreman) or [Invoker](http://invoker.codemancers.com)
to launch the webpack server, both of these tools have basic support for a
`.env` file (Invoker also supports `.env.local`), so no further configuration
is needed.

However, if you run the webpack server without Foreman/Invoker, or if you
want more control over what `.env` files to load, you can use the
[dotenv npm package](https://github.com/motdotla/dotenv). Here is what you could
do to support a "Ruby-like" dotenv:

```
yarn add dotenv
```

```javascript
// config/webpack/environment.js

...
const { environment } = require('@rails/webpacker')
const webpack = require('webpack')
const dotenv = require('dotenv')

const dotenvFiles = [
  `.env.${process.env.NODE_ENV}.local`,
  '.env.local',
  `.env.${process.env.NODE_ENV}`,
  '.env'
]
dotenvFiles.forEach((dotenvFile) => {
  dotenv.config({ path: dotenvFile, silent: true })
})

environment.plugins.prepend('Environment', new webpack.EnvironmentPlugin(JSON.parse(JSON.stringify(process.env))))

module.exports = environment
```

**Warning:** using Foreman/Invoker and npm dotenv at the same time can result in
confusing behavior, in that Foreman/Invoker variables take precedence over
npm dotenv variables.

If you'd like to pass custom variables to the on demand compiler, use `Webpacker::Compiler.env` attribute.

```rb
Webpacker::Compiler.env['FRONTEND_API_KEY'] = 'your_secret_key'
```
