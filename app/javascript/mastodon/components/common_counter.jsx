// @ts-check
import React from 'react';
import { FormattedMessage } from 'react-intl';

/**
 * Returns custom renderer for one of the common counter types
 * @param {"statuses" | "following" | "followers"} counterType
 * Type of the counter
 * @param {boolean} isBold Whether display number must be displayed in bold
 * @returns {(displayNumber: JSX.Element, pluralReady: number) => JSX.Element}
 * Renderer function
 * @throws If counterType is not covered by this function
 */
export function counterRenderer(counterType, isBold = true) {
  /**
   * @type {(displayNumber: JSX.Element) => JSX.Element}
   */
  const renderCounter = isBold
    ? (displayNumber) => <strong>{displayNumber}</strong>
    : (displayNumber) => displayNumber;

  switch (counterType) {
  case 'statuses': {
    return (displayNumber, pluralReady) => (
      <FormattedMessage
        id='account.statuses_counter'
        defaultMessage='{count, plural, one {{counter} Post} other {{counter} Posts}}'
        values={{
          count: pluralReady,
          counter: renderCounter(displayNumber),
        }}
      />
    );
  }
  case 'following': {
    return (displayNumber, pluralReady) => (
      <FormattedMessage
        id='account.following_counter'
        defaultMessage='{count, plural, one {{counter} Following} other {{counter} Following}}'
        values={{
          count: pluralReady,
          counter: renderCounter(displayNumber),
        }}
      />
    );
  }
  case 'followers': {
    return (displayNumber, pluralReady) => (
      <FormattedMessage
        id='account.followers_counter'
        defaultMessage='{count, plural, one {{counter} Follower} other {{counter} Followers}}'
        values={{
          count: pluralReady,
          counter: renderCounter(displayNumber),
        }}
      />
    );
  }
  default: throw Error(`Incorrect counter name: ${counterType}. Ensure it accepted by commonCounter function`);
  }
}
