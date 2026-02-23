import { useCallback, useMemo } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { Link } from 'react-router-dom';

import { EmojiHTML } from '@/mastodon/components/emoji/html';
import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';
import {
  blockAccount,
  unblockAccount,
  muteAccount,
  unmuteAccount,
  followAccountSuccess,
  unpinAccount,
  pinAccount,
} from 'mastodon/actions/accounts';
import { showAlertForError } from 'mastodon/actions/alerts';
import { openModal } from 'mastodon/actions/modal';
import { initMuteModal } from 'mastodon/actions/mutes';
import { apiFollowAccount } from 'mastodon/api/accounts';
import { Avatar } from 'mastodon/components/avatar';
import { Button } from 'mastodon/components/button';
import { FollowersCounter } from 'mastodon/components/counters';
import { DisplayName } from 'mastodon/components/display_name';
import { Dropdown } from 'mastodon/components/dropdown_menu';
import { FollowButton } from 'mastodon/components/follow_button';
import { RelativeTimestamp } from 'mastodon/components/relative_timestamp';
import { ShortNumber } from 'mastodon/components/short_number';
import { Skeleton } from 'mastodon/components/skeleton';
import { VerifiedBadge } from 'mastodon/components/verified_badge';
import { useIdentity } from 'mastodon/identity_context';
import { me } from 'mastodon/initial_state';
import type { MenuItem } from 'mastodon/models/dropdown_menu';
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
  addToLists: {
    id: 'account.add_or_remove_from_list',
    defaultMessage: 'Add or Remove from lists',
  },
  openOriginalPage: {
    id: 'account.open_original_page',
    defaultMessage: 'Open original page',
  },
});

interface AccountProps {
  size?: number;
  id: string;
  hidden?: boolean;
  minimal?: boolean;
  defaultAction?: 'block' | 'mute';
  withBio?: boolean;
  withMenu?: boolean;
  extraAccountInfo?: React.ReactNode;
  children?: React.ReactNode;
}

export const Account: React.FC<AccountProps> = ({
  id,
  size = 46,
  hidden,
  minimal,
  defaultAction,
  withBio,
  withMenu = true,
  extraAccountInfo,
  children,
}) => {
  const intl = useIntl();
  const { signedIn } = useIdentity();
  const account = useAppSelector((state) => state.accounts.get(id));
  const relationship = useAppSelector((state) => state.relationships.get(id));
  const dispatch = useAppDispatch();
  const accountUrl = account?.url;
  const isRemote = account?.acct !== account?.username;

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

  const menu = useMemo(() => {
    let arr: MenuItem[] = [];

    if (defaultAction === 'mute') {
      const handleMuteNotifications = () => {
        dispatch(muteAccount(id, true));
      };

      const handleUnmuteNotifications = () => {
        dispatch(muteAccount(id, false));
      };

      arr = [
        {
          text: intl.formatMessage(
            relationship?.muting_notifications
              ? messages.unmute_notifications
              : messages.mute_notifications,
          ),
          action: relationship?.muting_notifications
            ? handleUnmuteNotifications
            : handleMuteNotifications,
        },
      ];
    } else if (defaultAction !== 'block') {
      if (isRemote && accountUrl) {
        arr.push({
          text: intl.formatMessage(messages.openOriginalPage),
          href: accountUrl,
        });
      }

      if (signedIn) {
        const handleAddToLists = () => {
          const openAddToListModal = () => {
            dispatch(
              openModal({
                modalType: 'LIST_ADDER',
                modalProps: {
                  accountId: id,
                },
              }),
            );
          };
          if (relationship?.following || relationship?.requested || id === me) {
            openAddToListModal();
          } else {
            dispatch(
              openModal({
                modalType: 'CONFIRM_FOLLOW_TO_LIST',
                modalProps: {
                  accountId: id,
                  onConfirm: () => {
                    apiFollowAccount(id)
                      .then((relationship) => {
                        dispatch(
                          followAccountSuccess({
                            relationship,
                            alreadyFollowing: false,
                          }),
                        );
                        openAddToListModal();
                      })
                      .catch((err: unknown) => {
                        dispatch(showAlertForError(err));
                      });
                  },
                },
              }),
            );
          }
        };

        arr.push({
          text: intl.formatMessage(messages.addToLists),
          action: handleAddToLists,
        });

        if (id !== me && (relationship?.following || relationship?.requested)) {
          const handleEndorseToggle = () => {
            if (relationship.endorsed) {
              dispatch(unpinAccount(id));
            } else {
              dispatch(pinAccount(id));
            }
          };
          arr.push({
            text: intl.formatMessage(
              // Defined in features/account_timeline/components/account_header.tsx
              relationship.endorsed
                ? { id: 'account.unendorse' }
                : { id: 'account.endorse' },
            ),
            action: handleEndorseToggle,
          });
        }
      }
    }

    return arr;
  }, [
    dispatch,
    intl,
    id,
    accountUrl,
    relationship,
    defaultAction,
    isRemote,
    signedIn,
  ]);

  if (hidden) {
    return (
      <>
        {account?.display_name}
        {account?.username}
      </>
    );
  }

  let button: React.ReactNode;
  let dropdown: React.ReactNode;

  if (menu.length > 0 && withMenu) {
    dropdown = (
      <Dropdown
        items={menu}
        icon='ellipsis-h'
        iconComponent={MoreHorizIcon}
        title={intl.formatMessage(messages.more)}
      />
    );
  }

  if (defaultAction === 'block') {
    button = (
      <Button
        text={intl.formatMessage(
          relationship?.blocking ? messages.unblock : messages.block,
        )}
        onClick={handleBlock}
      />
    );
  } else if (defaultAction === 'mute') {
    button = (
      <Button
        text={intl.formatMessage(
          relationship?.muting ? messages.unmute : messages.mute,
        )}
        onClick={handleMute}
      />
    );
  } else {
    button = <FollowButton accountId={id} />;
  }

  let muteTimeRemaining: React.ReactNode;

  if (account?.mute_expires_at) {
    muteTimeRemaining = (
      <>
        · <RelativeTimestamp timestamp={account.mute_expires_at} futureDate />
      </>
    );
  }

  let verification: React.ReactNode;

  const firstVerifiedField = account?.fields.find((item) => !!item.verified_at);

  if (firstVerifiedField) {
    verification = <VerifiedBadge link={firstVerifiedField.value} />;
  }

  return (
    <div
      className={classNames('account', {
        'account--minimal': minimal,
      })}
    >
      <div
        className={classNames('account__wrapper', {
          'account__wrapper--with-bio': account && withBio,
        })}
      >
        <div className='account__info-wrapper'>
          <Link
            className='account__display-name focusable'
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

          {account &&
            withBio &&
            (account.note.length > 0 ? (
              <EmojiHTML
                className='account__note translate'
                htmlString={account.note_emojified}
                extraEmojis={account.emojis}
              />
            ) : (
              <div className='account__note account__note--missing'>
                <FormattedMessage
                  id='account.no_bio'
                  defaultMessage='No description provided.'
                />
              </div>
            ))}

          {extraAccountInfo}
        </div>

        {!minimal && (
          <div className='account__relationship'>
            {dropdown}
            {button}
          </div>
        )}

        {children}
      </div>
    </div>
  );
};
