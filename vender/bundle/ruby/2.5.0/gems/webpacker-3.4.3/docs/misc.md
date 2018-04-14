# How-Tos


## Ignoring swap files

If you are using vim or emacs and want to ignore certain files you can add `ignore-loader`:

```
yarn add ignore-loader
```

and add `ignore-loader` to `config/webpack/environment.js`

```js
// ignores vue~ swap files
const { environment } = require('@rails/webpacker')
environment.loaders.append('ignore', {
  test:  /.vue~$/,
  loader: 'ignore-loader'
})
```

And now all files with `.vue~` will be ignored by the webpack compiler.
