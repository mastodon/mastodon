// @ts-check

const FALSE_VALUES = [
  false,
  0,
  '0',
  'f',
  'F',
  'false',
  'FALSE',
  'off',
  'OFF',
];

/**
 * @param {any} value
 * @returns {boolean}
 */
const isTruthy = value =>
  value && !FALSE_VALUES.includes(value);

exports.isTruthy = isTruthy;
