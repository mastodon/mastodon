import type { FC } from 'react';

import { LinkedDisplayName } from '@/mastodon/components/display_name';
import { Avatar } from 'mastodon/components/avatar';
import { useAppSelector } from 'mastodon/store';

export const AuthorLink: FC<{ accountId: string }> = ({ accountId }) => {
  const account = useAppSelector((state) => state.accounts.get(accountId));

  if (!account) {
    return null;
  }

  return (
    <LinkedDisplayName
      displayProps={{ account, variant: 'simple' }}
      className='story__details__shared__author-link'
    >
      <Avatar account={account} size={16} />
    </LinkedDisplayName>
  );
};
