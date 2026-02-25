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

export const AccountNumberFields: FC<{ accountId: string }> = ({
  accountId,
}) => {
  const intl = useIntl();
  const account = useAccount(accountId);

  if (!account) {
    return null;
  }

  return (
    <div
      className={classNames(
        'account__header__extra__links',
        isRedesignEnabled() && classes.fieldNumbersWrapper,
      )}
    >
      {!isRedesignEnabled() && (
        <NavLink
          to={`/@${account.acct}`}
          title={intl.formatNumber(account.statuses_count)}
        >
          <ShortNumber
            value={account.statuses_count}
            renderer={StatusesCounter}
          />
        </NavLink>
      )}

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

      {isRedesignEnabled() && (
        <FormattedMessage
          id='account.joined_long'
          defaultMessage='Joined on {date}'
          values={{
            date: (
              <strong>
                <FormattedDateWrapper
                  value={account.created_at}
                  year='numeric'
                  month='short'
                  day='2-digit'
                />
              </strong>
            ),
          }}
        />
      )}
    </div>
  );
};
