import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import type { List as ImmutableList } from 'immutable';

import { LimitedAccountHint } from '@/mastodon/features/account_timeline/components/limited_account_hint';
import { useAccountVisibility } from '@/mastodon/hooks/useAccountVisibility';
import type { Account } from '@/mastodon/models/account';

import { RemoteHint } from './remote';

export const EmptyMessage: FC<{
  account: Account;
  followerIds?: ImmutableList<string>;
}> = ({ account, followerIds }) => {
  const { blockedBy, hidden, suspended } = useAccountVisibility(account.id);

  if (suspended) {
    return (
      <FormattedMessage
        id='empty_column.account_suspended'
        defaultMessage='Account suspended'
      />
    );
  }

  if (hidden) {
    return <LimitedAccountHint accountId={account.id} />;
  }

  if (blockedBy) {
    return (
      <FormattedMessage
        id='empty_column.account_unavailable'
        defaultMessage='Profile unavailable'
      />
    );
  }

  // If we don't have the Immutable list, then we're still loading.
  if (!followerIds) {
    return null;
  }

  if (account.hide_collections && followerIds.isEmpty()) {
    return (
      <FormattedMessage
        id='empty_column.account_hides_collections'
        defaultMessage='This user has chosen to not make this information available'
      />
    );
  }

  const domain = account.acct.split('@')[1];
  if (domain && followerIds.isEmpty()) {
    return <RemoteHint domain={domain} url={account.url} />;
  }

  return (
    <FormattedMessage
      id='account.followers.empty'
      defaultMessage='No one follows this user yet.'
    />
  );
};
