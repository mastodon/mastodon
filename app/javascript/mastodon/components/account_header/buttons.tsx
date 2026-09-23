import { useCallback } from 'react';
import type { FC } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { BellIcon, BellSlashIcon } from '@phosphor-icons/react';

import { followAccount } from '@/mastodon/actions/accounts';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useFollowReference } from '@/mastodon/hooks/useFollowReference';
import { getAccountHidden } from '@/mastodon/selectors/accounts';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import { isRedesignEnabled } from '@/mastodon/utils/environment';
import NotificationsIcon from '@/material-icons/400-24px/notifications.svg?react';
import NotificationsActiveIcon from '@/material-icons/400-24px/notifications_active-fill.svg?react';

import { ToggleIconButton } from '../button/redesign';
import { CopyIconButton, CopyIconButtonLegacy } from '../copy_button';
import { FollowButton } from '../follow_button';
import { IconButton as LegacyIconButton } from '../icon_button';

import { AccountMenu } from './menu';
import classes from './styles.module.scss';

const messages = defineMessages({
  enableNotifications: {
    id: 'account.enable_notifications',
    defaultMessage: 'Notify me when @{name} posts',
  },
  disableNotifications: {
    id: 'account.disable_notifications',
    defaultMessage: 'Stop notifying me when @{name} posts',
  },
  share: { id: 'account.share', defaultMessage: "Share @{name}'s profile" },
  copy: { id: 'account.copy', defaultMessage: 'Copy link to profile' },
});

interface AccountButtonsProps {
  accountId: string;
  className?: string;
  noShare?: boolean;
  forceMenu?: boolean;
}

export const AccountButtons: FC<AccountButtonsProps> = ({
  accountId,
  className,
  noShare,
  forceMenu,
}) => {
  const hidden = useAppSelector((state) => getAccountHidden(state, accountId));
  const me = useAppSelector((state) => state.meta.get('me') as string);

  return (
    <div className={className}>
      {!hidden && (
        <AccountButtonsOther accountId={accountId} noShare={noShare} />
      )}
      {(accountId !== me || forceMenu) && <AccountMenu accountId={accountId} />}
    </div>
  );
};

const AccountButtonsOther: FC<
  Pick<AccountButtonsProps, 'accountId' | 'noShare'>
> = ({ accountId, noShare }) => {
  const intl = useIntl();
  const account = useAccount(accountId);
  const relationship = useAppSelector((state) =>
    state.relationships.get(accountId),
  );

  const dispatch = useAppDispatch();
  const handleNotifyToggle = useCallback(() => {
    if (account) {
      dispatch(followAccount(account.id, { notify: !relationship?.notifying }));
    }
  }, [dispatch, account, relationship]);

  const reference = useFollowReference('profile');

  if (!account) {
    return null;
  }

  const isMovedAndUnfollowedAccount = account.moved && !relationship?.following;
  const isFollowing = relationship?.requested || relationship?.following;

  return (
    <>
      {!isMovedAndUnfollowedAccount && (
        <FollowButton
          compact={isRedesignEnabled()}
          accountId={accountId}
          className={classes.followButton}
          withUnmute={false}
          labelLength='long'
          reference={reference}
        />
      )}
      {isFollowing &&
        (isRedesignEnabled() ? (
          <ToggleIconButton
            size='sm'
            icon={relationship.notifying ? BellSlashIcon : BellIcon}
            active={relationship.notifying}
            onClick={handleNotifyToggle}
            title={intl.formatMessage(
              relationship.notifying
                ? messages.disableNotifications
                : messages.enableNotifications,
              { name: account.username },
            )}
          >
            {intl.formatMessage(messages.enableNotifications, {
              name: account.username,
            })}
          </ToggleIconButton>
        ) : (
          <LegacyIconButton
            icon={relationship.notifying ? 'bell' : 'bell-o'}
            iconComponent={
              relationship.notifying
                ? NotificationsActiveIcon
                : NotificationsIcon
            }
            active={relationship.notifying}
            title={intl.formatMessage(
              relationship.notifying
                ? messages.disableNotifications
                : messages.enableNotifications,
              { name: account.username },
            )}
            onClick={handleNotifyToggle}
          />
        ))}
      {!noShare &&
        (isRedesignEnabled() ? (
          <CopyIconButton
            title={intl.formatMessage(messages.copy)}
            value={account.url}
            size='sm'
          />
        ) : (
          <CopyIconButtonLegacy
            className='optional'
            title={intl.formatMessage(messages.copy)}
            value={account.url}
          />
        ))}
    </>
  );
};
