import type { ValueOf } from 'flavours/glitch/types/util';

export const DECIMAL_UNITS = Object.freeze({
  ONE: 1,
  TEN: 10,
  HUNDRED: 100,
  THOUSAND: 1_000,
  MILLION: 1_000_000,
  BILLION: 1_000_000_000,
  TRILLION: 1_000_000_000_000,
});
export type DecimalUnits = ValueOf<typeof DECIMAL_UNITS>;

const TEN_THOUSAND = DECIMAL_UNITS.THOUSAND * 10;
const TEN_MILLIONS = DECIMAL_UNITS.MILLION * 10;

export type ShortNumber = [number, DecimalUnits, 0 | 1]; // Array of: shorten number, unit of shorten number and maximum fraction digits

/**
 * @param sourceNumber Number to convert to short number
 * @returns Calculated short number
 * @example
 * shortNumber(5936);
 * // => [5.936, 1000, 1]
 */
export function toShortNumber(sourceNumber: number): ShortNumber {
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
    return [sourceNumber / DECIMAL_UNITS.BILLION, DECIMAL_UNITS.BILLION, 0];
  }

  return [sourceNumber, DECIMAL_UNITS.ONE, 0];
}

/**
 * @param sourceNumber Original number that is shortened
 * @param division The scale in which short number is displayed
 * @returns Number that can be used for plurals when short form used
 * @example
 * pluralReady(1793, DECIMAL_UNITS.THOUSAND)
 * // => 1790
 */
export function pluralReady(
  sourceNumber: number,
  division: DecimalUnits | null,
): number {
  if (division == null || division < DECIMAL_UNITS.HUNDRED) {
    return sourceNumber;
  }

  const closestScale = division / DECIMAL_UNITS.TEN;

  return Math.trunc(sourceNumber / closestScale) * closestScale;
}

export function roundTo10(num: number): number {
  return Math.round(num * 0.1) / 0.1;
}
