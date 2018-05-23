# ES6


## Babel

Webpacker ships with [babel](https://babeljs.io/) - a JavaScript compiler so
you can use next generation JavaScript, today. The Webpacker installer sets up a
standard `.babelrc` file in your app root, which will work great in most cases
because of [babel-env-preset](https://github.com/babel/babel-preset-env).

Following ES6/7 features are supported out of the box:

* Async/await.
* Object Rest/Spread Properties.
* Exponentiation Operator.
* Dynamic import() - useful for route level code-splitting
* Class Fields and Static Properties.

We have also included [babel polyfill](https://babeljs.io/docs/usage/polyfill/)
that includes a custom regenerator runtime and core-js.

Don't forget to import `babel-polyfill` in your main entry point like so:

```js
import "babel-polyfill"
```


## Module import() vs require()

While you are free to use `require()` and `module.exports`, we encourage you
to use `import` and `export` instead since it reads and looks much better.

```js
import Button from 'react-bootstrap/lib/Button'

// or
import { Button } from 'react-bootstrap'

class Foo {
  // code...
}

export default Foo
import Foo from './foo'
```

You can also use named export and import

```js
export const foo = () => console.log('hello world')
import { foo } from './foo'
```
