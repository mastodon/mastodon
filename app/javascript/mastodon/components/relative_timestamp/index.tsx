import { useEffect, useMemo, useState } from 'react';
import type { FC } from 'react';

import type { IntlShape } from 'react-intl';
import { defineMessages, useIntl } from 'react-intl';

import type { TimeUnit } from '@/mastodon/utils/time';
import {
  isSameYear,
  isToday,
  relativeTimeParts,
  unitToTime,
} from '@/mastodon/utils/time';

const messages = defineMessages({
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

const dateFormatOptions = {
  year: 'numeric',
  month: 'short',
  day: '2-digit',
  hour: '2-digit',
  minute: '2-digit',
} as const;

const shortFormatOptions = {
  month: 'short',
  day: 'numeric',
} as const;

const NOW_SECONDS = 10;
const DAYS_LIMIT = 7;

export const RelativeTimestamp: FC<{
  timestamp: string;
  long?: boolean;
  noTime?: boolean;
  noFuture?: boolean;
}> = ({ timestamp, long = false, noTime = false, noFuture = false }) => {
  const intl = useIntl();

  const [now, setNow] = useState(() => Date.now());

  const date = useMemo(() => {
    const date = new Date(timestamp);
    return noFuture ? new Date(Math.min(date.getTime(), now)) : date;
  }, [noFuture, now, timestamp]);
  const daysOnly = !timestamp.includes('T') || noTime;
  const delta = useMemo(
    () => relativeTimeParts(date.getTime(), now),
    [date, now],
  );

  useEffect(() => {
    const timerId = setInterval(() => {
      setNow(Date.now());
    }, unitToTime(delta.unit));

    return () => {
      clearInterval(timerId);
    };
  }, [delta.unit]);

  const relativeTime = useMemo(() => {
    const ts = date.getTime();
    // Show the date if more than a week old.
    if (delta.unit === 'day' && delta.value < -1 * DAYS_LIMIT) {
      return intl.formatDate(date, {
        ...shortFormatOptions,
        // Only show the year if it's different from the current year.
        year: isSameYear(ts, now) ? undefined : 'numeric',
      });
    }

    // If we're only showing days, show "today" for the current day.
    if (daysOnly && isToday(ts, now)) {
      return intl.formatMessage(messages.today);
    }

    return formatRelativeTime({
      value: delta.value,
      unit: delta.unit,
      intl,
      short: !long,
    });
  }, [date, daysOnly, delta.unit, delta.value, intl, now, long]);

  return (
    <time dateTime={timestamp} title={intl.formatDate(date, dateFormatOptions)}>
      {relativeTime}
    </time>
  );
};

function formatRelativeTime({
  value,
  unit,
  intl,
  short = false,
}: {
  value: number;
  unit: TimeUnit;
  intl: IntlShape;
  short?: boolean;
}) {
  // Time remaining
  if (value > 0) {
    if (unit === 'day') {
      return intl.formatMessage(
        short ? messages.days_remaining : messages.days_remaining,
        { number: value },
      );
    }

    if (unit === 'hour') {
      return intl.formatMessage(
        short ? messages.hours_remaining : messages.hours_remaining,
        { number: value },
      );
    }

    if (unit === 'minute') {
      return intl.formatMessage(
        short ? messages.minutes_remaining : messages.minutes_remaining,
        { number: value },
      );
    }

    if (value > NOW_SECONDS) {
      return intl.formatMessage(
        short ? messages.seconds_remaining : messages.seconds_remaining,
        { number: value },
      );
    }

    return intl.formatMessage(
      short ? messages.moments_remaining : messages.moments_remaining,
    );
  }

  // Time ago
  const absValue = Math.abs(value);
  if (unit === 'day') {
    return intl.formatMessage(short ? messages.days : messages.days_full, {
      number: absValue,
    });
  }

  if (unit === 'hour') {
    return intl.formatMessage(short ? messages.hours : messages.hours_full, {
      number: absValue,
    });
  }

  if (unit === 'minute') {
    return intl.formatMessage(
      short ? messages.minutes : messages.minutes_full,
      { number: absValue },
    );
  }

  if (absValue >= NOW_SECONDS) {
    return intl.formatMessage(
      short ? messages.seconds : messages.seconds_full,
      { number: absValue },
    );
  }

  return intl.formatMessage(short ? messages.just_now : messages.just_now_full);
}
