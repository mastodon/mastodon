import { openDB } from 'idb';

import { findMissingLocales, testClearLocales } from './database';

const db = {
  count: vitest.fn(() => 0),
  get: vitest.fn(),
  getAll: vitest.fn(() => []),
  getAllFromIndex: vitest.fn(() => []),
  put: vitest.fn(),
  transaction: vitest.fn(() => ({ store: db, done: vitest.fn() })),
} as const;
vitest.mock('idb', () => {
  return {
    openDB: vitest.fn(() => db),
  };
});

describe('findMissingLocales', () => {
  beforeEach(() => {
    testClearLocales();
    db.count.mockClear();
  });
  test('calls database for each missing item', async () => {
    const arg = ['bn', 'en'];
    const actual = await findMissingLocales(arg);
    expect(actual).toHaveLength(arg.length);
    expect(db.count).toBeCalledTimes(arg.length);
  });

  test('coerces to valid locale and dedupes', async () => {
    const arg = ['foo', 'bar'];
    const actual = await findMissingLocales(arg);
    expect(actual).toHaveLength(1);
    expect(actual[0]).toBe('en');
  });

  test('does not query DB for already checked locales', async () => {
    db.count.mockResolvedValue(1);
    await findMissingLocales(['en']);
    expect(db.count).toHaveBeenCalledOnce();
    await findMissingLocales(['en']);
    expect(db.count).toHaveBeenCalledOnce();
    expect(vitest.mocked(openDB)).toHaveBeenCalledOnce();
  });

  test('empty arg array does not query the DB', async () => {
    await findMissingLocales([]);
    expect(db.count).not.toHaveBeenCalled();
  });
});
