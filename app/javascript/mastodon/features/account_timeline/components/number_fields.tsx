import { useMemo } from 'react';
import type { FC } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import { FormattedDateWrapper } from '@/mastodon/components/formatted_date';
import {
  NumberFields,
  NumberFieldsItem,
} from '@/mastodon/components/number_fields';
import { ShortNumber } from '@/mastodon/components/short_number';
import { useAccount } from '@/mastodon/hooks/useAccount';

export const AccountNumberFields: FC<{ accountId: string }> = ({
  accountId,
}) => {
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
    <NumberFields>
      <NumberFieldsItem
        label={
          <FormattedMessage id='account.followers' defaultMessage='Followers' />
        }
        hint={intl.formatNumber(account.followers_count)}
        link={`/@${account.acct}/followers`}
      >
        <ShortNumber value={account.followers_count} />
      </NumberFieldsItem>

      <NumberFieldsItem
        label={
          <FormattedMessage id='account.following' defaultMessage='Following' />
        }
        hint={intl.formatNumber(account.following_count)}
        link={`/@${account.acct}/following`}
      >
        <ShortNumber value={account.following_count} />
      </NumberFieldsItem>

      <NumberFieldsItem
        label={<FormattedMessage id='account.posts' defaultMessage='Posts' />}
        hint={intl.formatNumber(account.statuses_count)}
      >
        <ShortNumber value={account.statuses_count} />
      </NumberFieldsItem>

      <NumberFieldsItem
        label={
          <FormattedMessage id='account.joined_short' defaultMessage='Joined' />
        }
        hint={intl.formatDate(account.created_at)}
      >
        {createdThisYear ? (
          <FormattedDateWrapper
            value={account.created_at}
            month='short'
            day='2-digit'
          />
        ) : (
          <FormattedDateWrapper value={account.created_at} year='numeric' />
        )}
      </NumberFieldsItem>
    </NumberFields>
  );
};
