import type { FC } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { useAccount } from '@/mastodon/hooks/useAccount';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';
import { useFeaturedHashtags } from '@/mastodon/hooks/useFeaturedHashtags';

import { AccountEditColumn, AccountEditEmptyColumn } from './components/column';

const messages = defineMessages({
  columnTitle: {
    id: 'account_edit_tags.column_title',
    defaultMessage: 'Edit featured hashtags',
  },
});

export const AccountEditFeaturedTags: FC = () => {
  const accountId = useCurrentAccountId();
  const account = useAccount(accountId);
  const intl = useIntl();

  useFeaturedHashtags(accountId);

  if (!accountId || !account) {
    return <AccountEditEmptyColumn notFound={!accountId} />;
  }

  return (
    <AccountEditColumn
      title={intl.formatMessage(messages.columnTitle)}
      acct={account.acct}
    >
      here
    </AccountEditColumn>
  );
};
