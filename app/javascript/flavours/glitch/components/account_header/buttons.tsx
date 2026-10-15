import { useCallback } from 'react';
import type { FC } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { ChatCircleDotsIcon, UserMinusIcon } from '@phosphor-icons/react';

import { directCompose } from '@/flavours/glitch/actions/compose';
import { openModal } from '@/flavours/glitch/actions/modal';
import { useAccount } from '@/flavours/glitch/hooks/useAccount';
import { useFollowReference } from '@/flavours/glitch/hooks/useFollowReference';
import { getAccountHidden } from '@/flavours/glitch/selectors/accounts';
import { useAppDispatch, useAppSelector } from '@/flavours/glitch/store';
import { isRedesignEnabled } from '@/flavours/glitch/utils/environment';

import { Button, IconButton } from '../button/redesign';
import { CopyIconButton } from '../copy_button';
import { FollowButton } from '../follow_button';

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

  const sendDirectMessage = useCallback(() => {
    if (account) {
      dispatch(directCompose(account));
    }
  }, [dispatch, account]);

  const confirmUnfollow = useCallback(() => {
    if (account) {
      dispatch(
        openModal({ modalType: 'CONFIRM_UNFOLLOW', modalProps: { account } }),
      );
    }
  }, [dispatch, account]);

  const reference = useFollowReference('profile');

  if (!account) {
    return null;
  }

  const isMovedAndUnfollowedAccount = account.moved && !relationship?.following;
  const isFollowing = relationship?.following;

  return (
    <>
      {!isFollowing && !isMovedAndUnfollowedAccount && (
        <FollowButton
          compact={isRedesignEnabled()}
          accountId={accountId}
          className={classes.followButton}
          withUnmute={false}
          labelLength='long'
          reference={reference}
        />
      )}
      {isFollowing && (
        <>
          <Button
            leadingIcon={ChatCircleDotsIcon}
            size='sm'
            variant='solid'
            color='accent'
            onClick={sendDirectMessage}
          >
            <FormattedMessage
              id='account.menu.message'
              defaultMessage='Message'
              description='Message refers to a direct message. For languages where this is confusing, "chat" or "direct message" can be used.'
            />
          </Button>
          <IconButton icon={UserMinusIcon} size='sm' onClick={confirmUnfollow}>
            <FormattedMessage id='account.unfollow' defaultMessage='Unfollow' />
          </IconButton>
        </>
      )}
      {!noShare && (
        <CopyIconButton
          title={intl.formatMessage(messages.copy)}
          value={account.url}
          size='sm'
        />
      )}
    </>
  );
};
