import React from 'react';

import { FormattedMessage, FormattedNumber } from 'react-intl';

import type { ShortNumber } from 'mastodon/utils/numbers';
import { DECIMAL_UNITS } from 'mastodon/utils/numbers';

interface GenericCounterRendererProps {
  value: ShortNumber;
}
export const GenericCounterRenderer: React.FC<GenericCounterRendererProps> = ({
  value,
}) => {
  const [rawNumber, unit, maxFractionDigits = 0] = value;

  const count = (
    <FormattedNumber
      value={rawNumber}
      maximumFractionDigits={maxFractionDigits}
    />
  );

  const values = { count, rawNumber };

  switch (unit) {
    case DECIMAL_UNITS.THOUSAND: {
      return (
        <FormattedMessage
          id='units.short.thousand'
          defaultMessage='{count}K'
          values={values}
        />
      );
    }
    case DECIMAL_UNITS.MILLION: {
      return (
        <FormattedMessage
          id='units.short.million'
          defaultMessage='{count}M'
          values={values}
        />
      );
    }
    case DECIMAL_UNITS.BILLION: {
      return (
        <FormattedMessage
          id='units.short.billion'
          defaultMessage='{count}B'
          values={values}
        />
      );
    }
    // Not sure if we should go farther - @Sasha-Sorokin
    default:
      return count;
  }
};

export const StatusesCounter = (
  displayNumber: React.ReactNode,
  pluralReady: number,
) => (
  <FormattedMessage
    id='account.statuses_counter'
    defaultMessage='{count, plural, one {{counter} Post} other {{counter} Posts}}'
    values={{
      count: pluralReady,
      counter: <strong>{displayNumber}</strong>,
    }}
  />
);

export const FollowingCounter = (
  displayNumber: React.ReactNode,
  pluralReady: number,
) => (
  <FormattedMessage
    id='account.following_counter'
    defaultMessage='{count, plural, one {{counter} Following} other {{counter} Following}}'
    values={{
      count: pluralReady,
      counter: <strong>{displayNumber}</strong>,
    }}
  />
);

export const FollowersCounter = (
  displayNumber: React.ReactNode,
  pluralReady: number,
) => (
  <FormattedMessage
    id='account.followers_counter'
    defaultMessage='{count, plural, one {{counter} Follower} other {{counter} Followers}}'
    values={{
      count: pluralReady,
      counter: <strong>{displayNumber}</strong>,
    }}
  />
);
