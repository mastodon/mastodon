import 'intl';
import 'intl/locale-data/jsonp/en.js';
import 'es6-symbol/implement';
import includes from 'array-includes';
import assign from 'object-assign';
import isNaN from 'is-nan';

if (!Array.prototype.includes) {
  includes.shim();
}

if (!Object.assign) {
  Object.assign = assign;
}

if (!Number.isNaN) {
  Number.isNaN = isNaN;
}
