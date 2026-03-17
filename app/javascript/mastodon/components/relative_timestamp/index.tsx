import { useEffect, useState } from 'react';
import type { FC } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { relativeTimeParts, unitToTime } from '@/mastodon/utils/time';

const messages = defineMessages({
  today: { id: 'relative_time.today', defaultMessage: 'today' },
  just_now: { id: 'relative_time.just_now', defaultMessage: 'now' },
  just_now_full: {
    id: 'relative_time.full.just_now',
    defaultMessage: 'just now',
  },
  moments_remaining: {
    id: 'time_remaining.moments',
    defaultMessage: 'Moments remaining',
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
  short?: boolean;
}> = ({ timestamp, short = true }) => {
  const intl = useIntl();

  const [now, setNow] = useState(() => Date.now());

  const date = new Date(timestamp);
  const daysOnly = !timestamp.includes('T');
  const delta = relativeTimeParts(date.getTime(), now);

  useEffect(() => {
    const timerId = setInterval(() => {
      setNow(Date.now());
    }, unitToTime(delta.unit));

    return () => {
      clearInterval(timerId);
    };
  }, [delta.unit]);

  const formatOptions = {
    style: short ? 'narrow' : 'long',
  } as const;

  let relativeTime = intl.formatRelativeTime(
    delta.value,
    delta.unit,
    formatOptions,
  );

  if (delta.unit === 'day' && delta.value > DAYS_LIMIT) {
    const sameYear = new Date(now).getFullYear() === date.getFullYear();
    relativeTime = intl.formatDate(date, {
      ...shortFormatOptions,
      year: sameYear ? undefined : 'numeric',
    });
  } else if (daysOnly && delta.unit !== 'day') {
    if (delta.unit === 'hour' && delta.value + new Date(now).getHours() < 24) {
      relativeTime = intl.formatMessage(messages.today);
    } else {
      relativeTime = intl.formatRelativeTime(
        delta.value > 0 ? 1 : -1,
        'day',
        formatOptions,
      );
    }
  } else if (delta.unit === 'second') {
    if (delta.value < NOW_SECONDS) {
      relativeTime = intl.formatMessage(
        short ? messages.just_now : messages.just_now_full,
      );
    } else if (delta.value > -1 * NOW_SECONDS) {
      relativeTime = intl.formatMessage(
        short ? messages.moments_remaining : messages.moments_remaining,
      );
    }
  }

  return (
    <time dateTime={timestamp} title={intl.formatDate(date, dateFormatOptions)}>
      {relativeTime}
    </time>
  );
};
