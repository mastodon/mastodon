import 'intl';
import 'intl/locale-data/jsonp/en';
import 'es6-symbol/implement';
import includes from 'array-includes';
import assign from 'object-assign';
import values from 'object.values';
import isNaN from 'is-nan';

if (!Array.prototype.includes) {
  includes.shim();
}

if (!Object.assign) {
  Object.assign = assign;
}

if (!Object.values) {
  values.shim();
}

if (!Number.isNaN) {
  Number.isNaN = isNaN;
}
