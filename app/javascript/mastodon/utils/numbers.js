// @ts-check

export const DECIMAL_UNITS = Object.freeze({
  ONE: 1,
  TEN: 10,
  HUNDRED: Math.pow(10, 2),
  THOUSAND: Math.pow(10, 3),
  MILLION: Math.pow(10, 6),
  BILLION: Math.pow(10, 9),
  TRILLION: Math.pow(10, 12),
});

const TEN_THOUSAND = DECIMAL_UNITS.THOUSAND * 10;
const TEN_MILLIONS = DECIMAL_UNITS.MILLION * 10;

/**
 * @typedef {[number, number, number]} ShortNumber
 * Array of: shorten number, unit of shorten number and maximum fraction digits
 */

/**
 * @param {number} sourceNumber Number to convert to short number
 * @returns {ShortNumber} Calculated short number
 * @example
 * shortNumber(5936);
 * // => [5.936, 1000, 1]
 */
export function toShortNumber(sourceNumber) {
  if (sourceNumber < DECIMAL_UNITS.THOUSAND) {
    return [sourceNumber, DECIMAL_UNITS.ONE, 0];
  } else if (sourceNumber < DECIMAL_UNITS.MILLION) {
    return [
      sourceNumber / DECIMAL_UNITS.THOUSAND,
      DECIMAL_UNITS.THOUSAND,
      sourceNumber < TEN_THOUSAND ? 1 : 0,
    ];
  } else if (sourceNumber < DECIMAL_UNITS.BILLION) {
    return [
      sourceNumber / DECIMAL_UNITS.MILLION,
      DECIMAL_UNITS.MILLION,
      sourceNumber < TEN_MILLIONS ? 1 : 0,
    ];
  } else if (sourceNumber < DECIMAL_UNITS.TRILLION) {
    return [
      sourceNumber / DECIMAL_UNITS.BILLION,
      DECIMAL_UNITS.BILLION,
      0,
    ];
  }

  return [sourceNumber, DECIMAL_UNITS.ONE, 0];
}

/**
 * @param {number} sourceNumber Original number that is shortened
 * @param {number} division The scale in which short number is displayed
 * @returns {number} Number that can be used for plurals when short form used
 * @example
 * pluralReady(1793, DECIMAL_UNITS.THOUSAND)
 * // => 1790
 */
export function pluralReady(sourceNumber, division) {
  if (division == null || division < DECIMAL_UNITS.HUNDRED) {
    return sourceNumber;
  }

  let closestScale = division / DECIMAL_UNITS.TEN;

  return Math.trunc(sourceNumber / closestScale) * closestScale;
}

/**
 * @param {number} num
 * @returns {number}
 */
export function roundTo10(num) {
  return Math.round(num * 0.1) / 0.1;
}
