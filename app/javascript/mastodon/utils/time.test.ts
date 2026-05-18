import { DAY, HOUR, MINUTE, relativeTimeParts, SECOND } from './time';

describe('relativeTimeParts', () => {
  const now = Date.now();

  test.concurrent.each([
    // Now
    [0, { value: 0, unit: 'second' }],

    // Past
    [-30 * SECOND, { value: -30, unit: 'second' }],
    [-90 * SECOND, { value: -2, unit: 'minute' }],
    [-30 * MINUTE, { value: -30, unit: 'minute' }],
    [-90 * MINUTE, { value: -2, unit: 'hour' }],
    [-5 * HOUR, { value: -5, unit: 'hour' }],
    [-24 * HOUR, { value: -1, unit: 'day' }],
    [-36 * HOUR, { value: -1, unit: 'day' }],
    [-47 * HOUR, { value: -2, unit: 'day' }],
    [-3 * DAY, { value: -3, unit: 'day' }],

    // Future
    [SECOND, { value: 1, unit: 'second' }],
    [59 * SECOND, { value: 59, unit: 'second' }],
    [MINUTE, { value: 1, unit: 'minute' }],
    [MINUTE + SECOND, { value: 1, unit: 'minute' }],
    [59 * MINUTE, { value: 59, unit: 'minute' }],
    [HOUR, { value: 1, unit: 'hour' }],
    [HOUR + MINUTE, { value: 1, unit: 'hour' }],
    [23 * HOUR, { value: 23, unit: 'hour' }],
    [DAY, { value: 1, unit: 'day' }],
    [DAY + HOUR, { value: 1, unit: 'day' }],
    [2 * DAY, { value: 2, unit: 'day' }],
  ])('should return correct value and unit for %d ms', (input, expected) => {
    expect(relativeTimeParts(now + input, now)).toMatchObject(expected);
  });
});
