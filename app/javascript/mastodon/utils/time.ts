export const SECOND = 1000;
export const MINUTE = SECOND * 60;
export const HOUR = MINUTE * 60;
export const DAY = HOUR * 24;

export type TimeUnit = 'second' | 'minute' | 'hour' | 'day';

export function relativeTimeParts(
  ts: number,
  now = Date.now(),
): { value: number; unit: TimeUnit } {
  const delta = ts - now;
  const absDelta = Math.abs(delta);

  if (absDelta < MINUTE) {
    return { value: Math.floor(delta / SECOND), unit: 'second' };
  }

  if (absDelta < HOUR) {
    return { value: Math.floor(delta / MINUTE), unit: 'minute' };
  }

  if (absDelta < DAY) {
    return { value: Math.floor(delta / HOUR), unit: 'hour' };
  }

  // Round instead of use floor as days are big enough that the value is usually off by a few hours.
  return { value: Math.round(delta / DAY), unit: 'day' };
}

export function isToday(ts: number, now = Date.now()): boolean {
  const date = new Date(ts);
  const nowDate = new Date(now);
  return (
    date.getDate() === nowDate.getDate() &&
    date.getMonth() === nowDate.getMonth() &&
    date.getFullYear() === nowDate.getFullYear()
  );
}

export function isSameYear(ts: number, now = Date.now()): boolean {
  const date = new Date(ts);
  const nowDate = new Date(now);
  return date.getFullYear() === nowDate.getFullYear();
}

export function unitToTime(unit: TimeUnit): number {
  switch (unit) {
    case 'second':
      return SECOND;
    case 'minute':
      return MINUTE;
    case 'hour':
      return HOUR;
    case 'day':
      return DAY;
  }
}
