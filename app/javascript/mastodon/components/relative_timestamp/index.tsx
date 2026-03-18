import { useEffect, useMemo, useState } from 'react';
import type { FC } from 'react';

import { useIntl } from 'react-intl';

import {
  formatTime,
  relativeTimeParts,
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
  noFuture?: boolean;
}> = ({ timestamp, long = false, noTime = false, noFuture = false }) => {
  const intl = useIntl();

  const [now, setNow] = useState(() => Date.now());

  const date = useMemo(() => {
    const date = new Date(timestamp);
    return noFuture ? new Date(Math.min(date.getTime(), now)) : date;
  }, [noFuture, now, timestamp]);
  const daysOnly = !timestamp.includes('T') || noTime;
  const { unit } = useMemo(
    () => relativeTimeParts(date.getTime(), now),
    [date, now],
  );

  useEffect(() => {
    const timerId = setInterval(() => {
      setNow(Date.now());
    }, unitToTime(unit));

    return () => {
      clearInterval(timerId);
    };
  }, [unit]);

  const relativeTime = useMemo(
    () =>
      formatTime({
        timestamp: date.getTime(),
        intl,
        short: !long,
        noTime: daysOnly,
      }),
    [date, intl, long, daysOnly],
  );

  return (
    <time dateTime={timestamp} title={intl.formatDate(date, dateFormatOptions)}>
      {relativeTime}
    </time>
  );
};
