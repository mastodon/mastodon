import { useEffect } from 'react';
import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { fetchRelationships } from '@/mastodon/actions/accounts';
import {
  AdminBadge,
  AutomatedBadge,
  Badge,
  BlockedBadge,
  GroupBadge,
  MutedBadge,
} from '@/mastodon/components/badge';
import { useAccount } from '@/mastodon/hooks/useAccount';
import type { AccountRole } from '@/mastodon/models/account';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

export const AccountBadges: FC<{ accountId: string }> = ({ accountId }) => {
  const account = useAccount(accountId);
  const localDomain = useAppSelector(
    (state) => state.meta.get('domain') as string,
  );
  const relationship = useAppSelector((state) =>
    state.relationships.get(accountId),
  );

  const dispatch = useAppDispatch();
  useEffect(() => {
    if (!relationship) {
      dispatch(fetchRelationships([accountId]));
    }
  }, [accountId, dispatch, relationship]);

  const badges = [];

  if (!account) {
    return null;
  }

  const domain = account.acct.includes('@')
    ? account.acct.split('@')[1]
    : localDomain;
  account.roles.forEach((role) => {
    if (isAdminBadge(role)) {
      badges.push(
        <AdminBadge
          key={role.id}
          label={role.name}
          domain={`(${domain})`}
          roleId={role.id}
        />,
      );
    } else {
      badges.push(
        <Badge
          key={role.id}
          label={role.name}
          domain={`(${domain})`}
          roleId={role.id}
        />,
      );
    }
  });

  if (account.bot) {
    badges.push(<AutomatedBadge key='bot-badge' />);
  }
  if (account.group) {
    badges.push(<GroupBadge key='group-badge' />);
  }
  if (relationship) {
    if (relationship.blocking) {
      badges.push(<BlockedBadge key='blocking' />);
    }
    if (relationship.domain_blocking) {
      badges.push(
        <BlockedBadge
          key='domain-blocking'
          domain={domain}
          label={
            <FormattedMessage
              id='account.badges.domain_blocked'
              defaultMessage='Blocked domain'
            />
          }
        />,
      );
    }
    if (relationship.muting) {
      badges.push(
        <MutedBadge
          key='muted-badge'
          expiresAt={relationship.muting_expires_at}
        />,
      );
    }
  }

  if (!badges.length) {
    return null;
  }

  return <div className={'account__header__badges'}>{badges}</div>;
};

function isAdminBadge(role: AccountRole) {
  const name = role.name.toLowerCase();
  return name === 'admin' || name === 'owner';
}
