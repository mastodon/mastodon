import {
  datetimeLocalToIso,
  formatDatetimeLocal,
  getDefaultScheduledAt,
  getMinimumScheduledAt,
  isScheduledAtValid,
  isoToDatetimeLocal,
} from './utils';

describe('scheduled status utils', () => {
  test('formats datetime-local values in local time', () => {
    const date = new Date(2025, 0, 2, 8, 5);

    expect(formatDatetimeLocal(date)).toBe('2025-01-02T08:05');
  });

  test('converts ISO values to datetime-local values', () => {
    const iso = new Date(2025, 0, 2, 8, 5).toISOString();

    expect(isoToDatetimeLocal(iso)).toBe('2025-01-02T08:05');
  });

  test('converts datetime-local values to ISO values', () => {
    const iso = datetimeLocalToIso('2025-01-02T08:05');

    expect(iso).toBe(new Date(2025, 0, 2, 8, 5).toISOString());
  });

  test('rounds default and minimum times up to the next step', () => {
    const now = new Date(2025, 0, 2, 8, 3, 30);

    expect(getMinimumScheduledAt(now)).toBe('2025-01-02T08:10');
    expect(getDefaultScheduledAt(now)).toBe('2025-01-02T08:35');
  });

  test('validates the minimum scheduling offset', () => {
    const now = new Date(2025, 0, 2, 8, 0);

    expect(isScheduledAtValid('2025-01-02T08:04', now)).toBe(false);
    expect(isScheduledAtValid('2025-01-02T08:05', now)).toBe(true);
  });
});
