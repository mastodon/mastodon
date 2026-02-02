import { useEffect } from 'react';
import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

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

import { isRedesignEnabled } from '../common';

import classes from './redesign.module.scss';

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

  const className = isRedesignEnabled() ? classes.badge : '';

  const domain = account.acct.includes('@')
    ? account.acct.split('@')[1]
    : localDomain;
  account.roles.forEach((role) => {
    if (isAdminBadge(role)) {
      badges.push(
        <AdminBadge
          key={role.id}
          label={role.name}
          className={className}
          domain={`(${domain})`}
          roleId={role.id}
        />,
      );
    } else {
      badges.push(
        <Badge
          key={role.id}
          label={role.name}
          className={className}
          domain={isRedesignEnabled() ? `(${domain})` : domain}
          roleId={role.id}
        />,
      );
    }
  });

  if (account.bot) {
    badges.push(<AutomatedBadge key='bot-badge' className={className} />);
  }
  if (account.group) {
    badges.push(<GroupBadge key='group-badge' className={className} />);
  }
  if (isRedesignEnabled() && relationship) {
    if (relationship.blocking) {
      badges.push(
        <BlockedBadge
          key='blocking'
          className={classNames(className, classes.badgeBlocked)}
        />,
      );
    } else if (relationship.domain_blocking) {
      badges.push(
        <BlockedBadge
          key='domain-blocking'
          className={classNames(className, classes.badgeBlocked)}
          domain={domain}
          label={
            <FormattedMessage
              id='account.badges.domain_blocked'
              defaultMessage='Blocked domain'
            />
          }
        />,
      );
    } else if (relationship.muting) {
      badges.push(
        <MutedBadge
          key='muted-badge'
          className={classNames(className, classes.badgeMuted)}
        />,
      );
    } else if (
      relationship.followed_by &&
      (relationship.following || relationship.requested)
    ) {
      badges.push(
        <Badge
          key='mutuals-badge'
          label={
            <FormattedMessage
              id='account.badges.mutuals'
              defaultMessage='You follow each other'
            />
          }
          className={className}
        />,
      );
    } else if (relationship.followed_by) {
      badges.push(
        <Badge
          key='follows-you-badge'
          label={
            <FormattedMessage
              id='account.badges.follows_you'
              defaultMessage='Follows you'
            />
          }
          className={className}
        />,
      );
    } else if (relationship.requested_by) {
      badges.push(
        <Badge
          key='requested-to-follow-badge'
          label={
            <FormattedMessage
              id='account.badges.requested_to_follow'
              defaultMessage='Requested to follow you'
            />
          }
          className={className}
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
  return isRedesignEnabled() && (name === 'admin' || name === 'owner');
}
