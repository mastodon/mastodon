import type { FC, ReactNode } from 'react';

import IconAdmin from '@/images/icons/icon_admin.svg?react';
import { AutomatedBadge, Badge, GroupBadge } from '@/mastodon/components/badge';
import { Icon } from '@/mastodon/components/icon';
import { useAccount } from '@/mastodon/hooks/useAccount';
import type { AccountRole } from '@/mastodon/models/account';
import { useAppSelector } from '@/mastodon/store';

import { isRedesignEnabled } from '../common';

import classes from './redesign.module.scss';

export const AccountBadges: FC<{ accountId: string }> = ({ accountId }) => {
  const account = useAccount(accountId);
  const localDomain = useAppSelector(
    (state) => state.meta.get('domain') as string,
  );
  const badges = [];

  if (!account) {
    return null;
  }

  const className = isRedesignEnabled() ? classes.badge : '';

  if (account.bot) {
    badges.push(<AutomatedBadge key='bot-badge' className={className} />);
  } else if (account.group) {
    badges.push(<GroupBadge key='group-badge' className={className} />);
  }

  const domain = account.acct.includes('@')
    ? account.acct.split('@')[1]
    : localDomain;
  account.roles.forEach((role) => {
    let icon: ReactNode = undefined;
    if (isAdminBadge(role)) {
      icon = (
        <Icon
          icon={IconAdmin}
          id='badge-admin'
          className={classes.badgeIcon}
          noFill
        />
      );
    }
    badges.push(
      <Badge
        key={role.id}
        label={role.name}
        className={className}
        domain={isRedesignEnabled() ? `(${domain})` : domain}
        roleId={role.id}
        icon={icon}
      />,
    );
  });

  if (!badges.length) {
    return null;
  }

  return <div className={'account__header__badges'}>{badges}</div>;
};

function isAdminBadge(role: AccountRole) {
  const name = role.name.toLowerCase();
  return isRedesignEnabled() && (name === 'admin' || name === 'owner');
}
