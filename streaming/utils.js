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
export function isTruthy(value) {
  return value && !FALSE_VALUES.includes(value);
}

/**
 * See app/lib/ascii_folder.rb for the canon definitions
 * of these constants
 */
const NON_ASCII_CHARS        = 'ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž';
const EQUIVALENT_ASCII_CHARS = 'AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz';

/**
 * @param {string} str
 * @returns {string}
 */
export function foldToASCII(str) {
  const regex = new RegExp(NON_ASCII_CHARS.split('').join('|'), 'g');

  return str.replace(regex, function(match) {
    const index = NON_ASCII_CHARS.indexOf(match);
    return EQUIVALENT_ASCII_CHARS[index];
  });
}

/**
 * @param {string} str
 * @returns {string}
 */
export function normalizeHashtag(str) {
  return foldToASCII(str.normalize('NFKC').toLowerCase()).replace(/[^\p{L}\p{N}_\u00b7\u200c]/gu, '');
}

/**
 * @param {string|string[]} arrayOrString
 * @returns {string}
 */
export function firstParam(arrayOrString) {
  if (Array.isArray(arrayOrString)) {
    return arrayOrString[0];
  } else {
    return arrayOrString;
  }
}
