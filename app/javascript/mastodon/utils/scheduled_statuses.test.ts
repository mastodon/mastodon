import {
  dateTimeLocalToISOString,
  isoStringToDateTimeLocal,
  minScheduledDateTimeLocal,
} from './scheduled_statuses';

describe('scheduled status date helpers', () => {
  test('converts an empty datetime-local value to null', () => {
    expect(dateTimeLocalToISOString('')).toBeNull();
  });

  test('converts datetime-local values into API timestamps', () => {
    expect(dateTimeLocalToISOString('2026-05-11T09:30')).toBe(
      new Date(2026, 4, 11, 9, 30).toISOString(),
    );
  });

  test('formats API timestamps as datetime-local values', () => {
    const date = new Date(2026, 4, 11, 9, 30);

    expect(isoStringToDateTimeLocal(date.toISOString())).toBe(
      '2026-05-11T09:30',
    );
  });

  test('creates a five-minute minimum datetime-local value', () => {
    const now = new Date(2026, 4, 11, 9, 30, 20);

    expect(minScheduledDateTimeLocal(now)).toBe('2026-05-11T09:35');
  });
});
