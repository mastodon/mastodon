import { useEffect, useMemo, useState } from 'react';
import type { FC } from 'react';

import { useIntl } from 'react-intl';

import {
  formatTime,
  MAX_TIMEOUT,
  relativeTimeParts,
  SECOND,
  unitToTime,
} from '@/mastodon/utils/time';

const dateFormatOptions = {
  year: 'numeric',
  month: 'short',
  day: '2-digit',
  hour: '2-digit',
  minute: '2-digit',
} as const;

export const RelativeTimestamp: FC<{
  timestamp: string;
  long?: boolean;
  noTime?: boolean;
  hasFuture?: boolean;
}> = ({ timestamp, long = false, noTime = false, hasFuture = false }) => {
  const intl = useIntl();

  const [now, setNow] = useState(() => Date.now());

  const date = useMemo(() => {
    const date = new Date(timestamp);
    return !hasFuture ? new Date(Math.min(date.getTime(), now)) : date;
  }, [hasFuture, now, timestamp]);
  const ts = date.getTime();

  useEffect(() => {
    let timeoutId = 0;
    const scheduleNextUpdate = () => {
      const { unit, delta } = relativeTimeParts(ts);
      const unitDelay = unitToTime(unit);
      const remainder = Math.abs(delta % unitDelay);
      const minDelay = 10 * SECOND;
      const delay = Math.min(
        Math.max(delta < 0 ? unitDelay - remainder : remainder, minDelay),
        MAX_TIMEOUT,
      );

      timeoutId = window.setTimeout(() => {
        setNow(Date.now());
        scheduleNextUpdate();
      }, delay);
    };

    scheduleNextUpdate();

    return () => {
      if (timeoutId) {
        clearTimeout(timeoutId);
      }
    };
  }, [ts]);

  const daysOnly = !timestamp.includes('T') || noTime;
  const relativeTime = useMemo(
    () =>
      formatTime({
        timestamp: ts,
        intl,
        short: !long,
        noTime: daysOnly,
        now,
      }),
    [ts, intl, long, daysOnly, now],
  );

  return (
    <time dateTime={timestamp} title={intl.formatDate(date, dateFormatOptions)}>
      {relativeTime}
    </time>
  );
};
