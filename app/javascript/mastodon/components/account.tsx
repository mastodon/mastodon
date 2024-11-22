import { useCallback } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { Link } from 'react-router-dom';

import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';
import {
  blockAccount,
  unblockAccount,
  muteAccount,
  unmuteAccount,
} from 'mastodon/actions/accounts';
import { initMuteModal } from 'mastodon/actions/mutes';
import { Avatar } from 'mastodon/components/avatar';
import { Button } from 'mastodon/components/button';
import { FollowersCounter } from 'mastodon/components/counters';
import { DisplayName } from 'mastodon/components/display_name';
import { FollowButton } from 'mastodon/components/follow_button';
import { RelativeTimestamp } from 'mastodon/components/relative_timestamp';
import { ShortNumber } from 'mastodon/components/short_number';
import { Skeleton } from 'mastodon/components/skeleton';
import { VerifiedBadge } from 'mastodon/components/verified_badge';
import DropdownMenu from 'mastodon/containers/dropdown_menu_container';
import { me } from 'mastodon/initial_state';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

const messages = defineMessages({
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  cancel_follow_request: {
    id: 'account.cancel_follow_request',
    defaultMessage: 'Withdraw follow request',
  },
  unblock: { id: 'account.unblock_short', defaultMessage: 'Unblock' },
  unmute: { id: 'account.unmute_short', defaultMessage: 'Unmute' },
  mute_notifications: {
    id: 'account.mute_notifications_short',
    defaultMessage: 'Mute notifications',
  },
  unmute_notifications: {
    id: 'account.unmute_notifications_short',
    defaultMessage: 'Unmute notifications',
  },
  mute: { id: 'account.mute_short', defaultMessage: 'Mute' },
  block: { id: 'account.block_short', defaultMessage: 'Block' },
  more: { id: 'status.more', defaultMessage: 'More' },
});

export const Account: React.FC<{
  size?: number;
  id: string;
  hidden?: boolean;
  minimal?: boolean;
  defaultAction?: 'block' | 'mute';
  withBio?: boolean;
}> = ({ id, size = 46, hidden, minimal, defaultAction, withBio }) => {
  const intl = useIntl();
  const account = useAppSelector((state) => state.accounts.get(id));
  const relationship = useAppSelector((state) => state.relationships.get(id));
  const dispatch = useAppDispatch();

  const handleBlock = useCallback(() => {
    if (relationship?.blocking) {
      dispatch(unblockAccount(id));
    } else {
      dispatch(blockAccount(id));
    }
  }, [dispatch, id, relationship]);

  const handleMute = useCallback(() => {
    if (relationship?.muting) {
      dispatch(unmuteAccount(id));
    } else {
      dispatch(initMuteModal(account));
    }
  }, [dispatch, id, account, relationship]);

  const handleMuteNotifications = useCallback(() => {
    dispatch(muteAccount(id, true));
  }, [dispatch, id]);

  const handleUnmuteNotifications = useCallback(() => {
    dispatch(muteAccount(id, false));
  }, [dispatch, id]);

  if (hidden) {
    return (
      <>
        {account?.display_name}
        {account?.username}
      </>
    );
  }

  let buttons;

  if (account && account.id !== me && relationship) {
    const { requested, blocking, muting } = relationship;

    if (requested) {
      buttons = <FollowButton accountId={id} />;
    } else if (blocking) {
      buttons = (
        <Button
          text={intl.formatMessage(messages.unblock)}
          onClick={handleBlock}
        />
      );
    } else if (muting) {
      const menu = [
        {
          text: intl.formatMessage(
            relationship.muting_notifications
              ? messages.unmute_notifications
              : messages.mute_notifications,
          ),
          action: relationship.muting_notifications
            ? handleUnmuteNotifications
            : handleMuteNotifications,
        },
      ];

      buttons = (
        <>
          <DropdownMenu
            items={menu}
            icon='ellipsis-h'
            iconComponent={MoreHorizIcon}
            direction='right'
            title={intl.formatMessage(messages.more)}
          />

          <Button
            text={intl.formatMessage(messages.unmute)}
            onClick={handleMute}
          />
        </>
      );
    } else if (defaultAction === 'mute') {
      buttons = (
        <Button text={intl.formatMessage(messages.mute)} onClick={handleMute} />
      );
    } else if (defaultAction === 'block') {
      buttons = (
        <Button
          text={intl.formatMessage(messages.block)}
          onClick={handleBlock}
        />
      );
    } else {
      buttons = <FollowButton accountId={id} />;
    }
  } else {
    buttons = <FollowButton accountId={id} />;
  }

  let muteTimeRemaining;

  if (account?.mute_expires_at) {
    muteTimeRemaining = (
      <>
        · <RelativeTimestamp timestamp={account.mute_expires_at} futureDate />
      </>
    );
  }

  let verification;

  const firstVerifiedField = account?.fields.find((item) => !!item.verified_at);

  if (firstVerifiedField) {
    verification = <VerifiedBadge link={firstVerifiedField.value} />;
  }

  return (
    <div className={classNames('account', { 'account--minimal': minimal })}>
      <div className='account__wrapper'>
        <Link
          className='account__display-name'
          title={account?.acct}
          to={`/@${account?.acct}`}
          data-hover-card-account={id}
        >
          <div className='account__avatar-wrapper'>
            {account ? (
              <Avatar account={account} size={size} />
            ) : (
              <Skeleton width={size} height={size} />
            )}
          </div>

          <div className='account__contents'>
            <DisplayName account={account} />

            {!minimal && (
              <div className='account__details'>
                {account ? (
                  <>
                    <ShortNumber
                      value={account.followers_count}
                      renderer={FollowersCounter}
                    />{' '}
                    {verification} {muteTimeRemaining}
                  </>
                ) : (
                  <Skeleton width='7ch' />
                )}
              </div>
            )}
          </div>
        </Link>

        {!minimal && <div className='account__relationship'>{buttons}</div>}
      </div>

      {account &&
        withBio &&
        (account.note.length > 0 ? (
          <div
            className='account__note translate'
            dangerouslySetInnerHTML={{ __html: account.note_emojified }}
          />
        ) : (
          <div className='account__note account__note--missing'>
            <FormattedMessage
              id='account.no_bio'
              defaultMessage='No description provided.'
            />
          </div>
        ))}
    </div>
  );
};
