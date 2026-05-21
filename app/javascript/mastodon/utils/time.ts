import type { IntlShape } from 'react-intl';
import { defineMessages } from 'react-intl';

export const SECOND = 1000;
export const MINUTE = SECOND * 60;
export const HOUR = MINUTE * 60;
export const DAY = HOUR * 24;

export const MAX_TIMEOUT = 2147483647; // Maximum delay for setTimeout in browsers (approximately 24.8 days)

export type TimeUnit = 'second' | 'minute' | 'hour' | 'day';

export function relativeTimeParts(
  ts: number,
  now = Date.now(),
): { value: number; unit: TimeUnit; delta: number } {
  const delta = ts - now;
  const absDelta = Math.abs(delta);

  if (absDelta < MINUTE) {
    return { value: Math.floor(delta / SECOND), unit: 'second', delta };
  }

  if (absDelta < HOUR) {
    return { value: Math.floor(delta / MINUTE), unit: 'minute', delta };
  }

  if (absDelta < DAY) {
    return { value: Math.floor(delta / HOUR), unit: 'hour', delta };
  }

  // Round instead of use floor as days are big enough that the value is usually off by a few hours.
  return { value: Math.round(delta / DAY), unit: 'day', delta };
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

const timeMessages = defineMessages({
  today: { id: 'relative_time.today', defaultMessage: 'today' },
  just_now: { id: 'relative_time.just_now', defaultMessage: 'now' },
  just_now_full: {
    id: 'relative_time.full.just_now',
    defaultMessage: 'just now',
  },
  seconds: { id: 'relative_time.seconds', defaultMessage: '{number}s' },
  seconds_full: {
    id: 'relative_time.full.seconds',
    defaultMessage: '{number, plural, one {# second} other {# seconds}} ago',
  },
  minutes: { id: 'relative_time.minutes', defaultMessage: '{number}m' },
  minutes_full: {
    id: 'relative_time.full.minutes',
    defaultMessage: '{number, plural, one {# minute} other {# minutes}} ago',
  },
  hours: { id: 'relative_time.hours', defaultMessage: '{number}h' },
  hours_full: {
    id: 'relative_time.full.hours',
    defaultMessage: '{number, plural, one {# hour} other {# hours}} ago',
  },
  days: { id: 'relative_time.days', defaultMessage: '{number}d' },
  days_full: {
    id: 'relative_time.full.days',
    defaultMessage: '{number, plural, one {# day} other {# days}} ago',
  },
  moments_remaining: {
    id: 'time_remaining.moments',
    defaultMessage: 'Moments remaining',
  },
  seconds_remaining: {
    id: 'time_remaining.seconds',
    defaultMessage: '{number, plural, one {# second} other {# seconds}} left',
  },
  minutes_remaining: {
    id: 'time_remaining.minutes',
    defaultMessage: '{number, plural, one {# minute} other {# minutes}} left',
  },
  hours_remaining: {
    id: 'time_remaining.hours',
    defaultMessage: '{number, plural, one {# hour} other {# hours}} left',
  },
  days_remaining: {
    id: 'time_remaining.days',
    defaultMessage: '{number, plural, one {# day} other {# days}} left',
  },
});

const DAYS_LIMIT = 7;
const NOW_SECONDS = 10;

export function formatTime({
  timestamp,
  intl,
  now = Date.now(),
  noTime = false,
  short = false,
}: {
  timestamp: number;
  intl: Pick<IntlShape, 'formatDate' | 'formatMessage'>;
  now?: number;
  noTime?: boolean;
  short?: boolean;
}) {
  const { value, unit } = relativeTimeParts(timestamp, now);

  // If we're only showing days, show "today" for the current day.
  if (noTime && isToday(timestamp, now)) {
    return intl.formatMessage(timeMessages.today);
  }

  if (value > 0) {
    return formatFuture({ value, unit, intl });
  }

  if (unit === 'day' && value < -DAYS_LIMIT) {
    return formatAbsoluteTime({ timestamp, intl, now });
  }

  return formatRelativePastTime({ value, unit, intl, short });
}

export function formatAbsoluteTime({
  timestamp,
  intl,
  now = Date.now(),
}: {
  timestamp: number;
  intl: Pick<IntlShape, 'formatDate'>;
  now?: number;
}) {
  return intl.formatDate(timestamp, {
    month: 'short',
    day: 'numeric',
    // Only show the year if it's different from the current year.
    year: isSameYear(timestamp, now) ? undefined : 'numeric',
  });
}

export function formatFuture({
  unit,
  value,
  intl,
}: {
  value: number;
  unit: TimeUnit;
  intl: Pick<IntlShape, 'formatMessage'>;
}) {
  if (unit === 'day') {
    return intl.formatMessage(timeMessages.days_remaining, { number: value });
  }

  if (unit === 'hour') {
    return intl.formatMessage(timeMessages.hours_remaining, {
      number: value,
    });
  }

  if (unit === 'minute') {
    return intl.formatMessage(timeMessages.minutes_remaining, {
      number: value,
    });
  }

  if (value > NOW_SECONDS) {
    return intl.formatMessage(timeMessages.seconds_remaining, {
      number: value,
    });
  }

  return intl.formatMessage(timeMessages.moments_remaining);
}

export function formatRelativePastTime({
  value,
  unit,
  intl,
  short = false,
}: {
  value: number;
  unit: TimeUnit;
  intl: Pick<IntlShape, 'formatMessage'>;
  short?: boolean;
}) {
  const absValue = Math.abs(value);
  if (unit === 'day') {
    return intl.formatMessage(
      short ? timeMessages.days : timeMessages.days_full,
      {
        number: absValue,
      },
    );
  }

  if (unit === 'hour') {
    return intl.formatMessage(
      short ? timeMessages.hours : timeMessages.hours_full,
      {
        number: absValue,
      },
    );
  }

  if (unit === 'minute') {
    return intl.formatMessage(
      short ? timeMessages.minutes : timeMessages.minutes_full,
      { number: absValue },
    );
  }

  if (absValue >= NOW_SECONDS) {
    return intl.formatMessage(
      short ? timeMessages.seconds : timeMessages.seconds_full,
      { number: absValue },
    );
  }

  return intl.formatMessage(
    short ? timeMessages.just_now : timeMessages.just_now_full,
  );
}
