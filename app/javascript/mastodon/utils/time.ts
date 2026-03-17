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
  } else if (absDelta < HOUR) {
    return { value: Math.floor(delta / MINUTE), unit: 'minute' };
  } else if (absDelta < DAY) {
    return { value: Math.floor(delta / HOUR), unit: 'hour' };
  }

  return { value: Math.floor(delta / DAY), unit: 'day' };
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
