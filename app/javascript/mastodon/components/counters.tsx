import type React from 'react';

import { FormattedMessage } from 'react-intl';

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

export const FollowersYouKnowCounter = (
  displayNumber: React.ReactNode,
  pluralReady: number,
) => (
  <FormattedMessage
    id='account.followers_you_know_counter'
    defaultMessage='{counter} you know'
    values={{
      count: pluralReady,
      counter: <strong>{displayNumber}</strong>,
    }}
  />
);
