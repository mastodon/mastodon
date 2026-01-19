import type { FC } from 'react';

import { AutomatedBadge, Badge, GroupBadge } from '@/mastodon/components/badge';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useAppSelector } from '@/mastodon/store';

export const AccountBadges: FC<{ accountId: string }> = ({ accountId }) => {
  const account = useAccount(accountId);
  const localDomain = useAppSelector(
    (state) => state.meta.get('domain') as string,
  );
  const badges = [];

  if (!account) {
    return null;
  }

  if (account.bot) {
    badges.push(<AutomatedBadge key='bot-badge' />);
  } else if (account.group) {
    badges.push(<GroupBadge key='group-badge' />);
  }

  const domain = account.acct.includes('@')
    ? account.acct.split('@')[1]
    : localDomain;
  account.roles.forEach((role) => {
    badges.push(
      <Badge
        key={`role-badge-${role.get('id')}`}
        label={<span>{role.get('name')}</span>}
        domain={domain}
        roleId={role.get('id')}
      />,
    );
  });

  if (!badges.length) {
    return null;
  }

  return <div className='account__header__badges'>{badges}</div>;
};
