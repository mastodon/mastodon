import { useMemo } from 'react';
import type { FC } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';
import { NavLink } from 'react-router-dom';

import {
  FollowersCounter,
  FollowingCounter,
  StatusesCounter,
} from '@/mastodon/components/counters';
import { FormattedDateWrapper } from '@/mastodon/components/formatted_date';
import { ShortNumber } from '@/mastodon/components/short_number';
import { useAccount } from '@/mastodon/hooks/useAccount';

import { isRedesignEnabled } from '../common';

import classes from './redesign.module.scss';

const LegacyNumberFields: FC<{ accountId: string }> = ({ accountId }) => {
  const intl = useIntl();
  const account = useAccount(accountId);

  if (!account) {
    return null;
  }

  return (
    <div className='account__header__extra__links'>
      <NavLink
        to={`/@${account.acct}`}
        title={intl.formatNumber(account.statuses_count)}
      >
        <ShortNumber
          value={account.statuses_count}
          renderer={StatusesCounter}
        />
      </NavLink>

      <NavLink
        exact
        to={`/@${account.acct}/following`}
        title={intl.formatNumber(account.following_count)}
      >
        <ShortNumber
          value={account.following_count}
          renderer={FollowingCounter}
        />
      </NavLink>

      <NavLink
        exact
        to={`/@${account.acct}/followers`}
        title={intl.formatNumber(account.followers_count)}
      >
        <ShortNumber
          value={account.followers_count}
          renderer={FollowersCounter}
        />
      </NavLink>
    </div>
  );
};

const RedesignNumberFields: FC<{ accountId: string }> = ({ accountId }) => {
  const intl = useIntl();
  const account = useAccount(accountId);
  const createdThisYear = useMemo(
    () => account?.created_at.includes(new Date().getFullYear().toString()),
    [account?.created_at],
  );

  if (!account) {
    return null;
  }

  return (
    <ul
      className={classNames(
        'account__header__extra__links',
        classes.fieldNumbersWrapper,
      )}
    >
      <li>
        <FormattedMessage id='account.posts' defaultMessage='Posts' />
        <strong>
          <ShortNumber value={account.statuses_count} />
        </strong>
      </li>

      <li>
        <FormattedMessage id='account.followers' defaultMessage='Followers' />
        <NavLink
          exact
          to={`/@${account.acct}/followers`}
          title={intl.formatNumber(account.followers_count)}
        >
          <ShortNumber value={account.followers_count} />
        </NavLink>
      </li>

      <li>
        <FormattedMessage id='account.following' defaultMessage='Following' />
        <NavLink
          exact
          to={`/@${account.acct}/following`}
          title={intl.formatNumber(account.following_count)}
        >
          <ShortNumber value={account.following_count} />
        </NavLink>
      </li>

      <li>
        <FormattedMessage id='account.joined_short' defaultMessage='Joined' />
        <strong>
          {createdThisYear ? (
            <FormattedDateWrapper
              value={account.created_at}
              month='short'
              day='2-digit'
            />
          ) : (
            <FormattedDateWrapper value={account.created_at} year='numeric' />
          )}
        </strong>
      </li>
    </ul>
  );
};

export const AccountNumberFields = isRedesignEnabled()
  ? RedesignNumberFields
  : LegacyNumberFields;
