import type { MouseEventHandler } from 'react';
import { useCallback } from 'react';

import { FormattedMessage, defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';
import { Link } from 'react-router-dom';

import {
  followAccount,
  unblockAccount,
  unmuteAccount,
} from 'mastodon/actions/accounts';
import { openModal } from 'mastodon/actions/modal';
import { Avatar } from 'mastodon/components/avatar';
import { Button } from 'mastodon/components/button';
import { DisplayName } from 'mastodon/components/display_name';
import { ShortNumber } from 'mastodon/components/short_number';
import { autoPlayGif, me } from 'mastodon/initial_state';
import type { Account } from 'mastodon/models/account';
import { makeGetAccount } from 'mastodon/selectors';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

const messages = defineMessages({
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  cancel_follow_request: {
    id: 'account.cancel_follow_request',
    defaultMessage: 'Withdraw follow request',
  },
  requested: {
    id: 'account.requested',
    defaultMessage: 'Awaiting approval. Click to cancel follow request',
  },
  unblock: { id: 'account.unblock_short', defaultMessage: 'Unblock' },
  unmute: { id: 'account.unmute_short', defaultMessage: 'Unmute' },
  edit_profile: { id: 'account.edit_profile', defaultMessage: 'Edit profile' },
});

const getAccount = makeGetAccount();

export const AccountCard: React.FC<{ accountId: string }> = ({ accountId }) => {
  const intl = useIntl();
  const account = useAppSelector((s) => getAccount(s, accountId));
  const dispatch = useAppDispatch();

  const handleMouseEnter = useCallback<MouseEventHandler>(
    ({ currentTarget }) => {
      if (autoPlayGif) {
        return;
      }
      const emojis =
        currentTarget.querySelectorAll<HTMLImageElement>('.custom-emoji');

      emojis.forEach((emoji) => {
        const original = emoji.getAttribute('data-original');
        if (original) emoji.src = original;
      });
    },
    [],
  );

  const handleMouseLeave = useCallback<MouseEventHandler>(
    ({ currentTarget }) => {
      if (autoPlayGif) {
        return;
      }

      const emojis =
        currentTarget.querySelectorAll<HTMLImageElement>('.custom-emoji');

      emojis.forEach((emoji) => {
        const staticUrl = emoji.getAttribute('data-static');
        if (staticUrl) emoji.src = staticUrl;
      });
    },
    [],
  );

  const handleFollow = useCallback(() => {
    if (!account) return;

    if (
      account.getIn(['relationship', 'following']) ||
      account.getIn(['relationship', 'requested'])
    ) {
      dispatch(
        openModal({ modalType: 'CONFIRM_UNFOLLOW', modalProps: { account } }),
      );
    } else {
      dispatch(followAccount(account.get('id')));
    }
  }, [account, dispatch]);

  const handleBlock = useCallback(() => {
    if (account?.relationship?.blocking) {
      dispatch(unblockAccount(account.get('id')));
    }
  }, [account, dispatch]);

  const handleMute = useCallback(() => {
    if (account?.relationship?.muting) {
      dispatch(unmuteAccount(account.get('id')));
    }
  }, [account, dispatch]);

  const handleEditProfile = useCallback(() => {
    window.open('/settings/profile', '_blank');
  }, []);

  if (!account) return null;

  let actionBtn;

  if (me !== account.get('id')) {
    if (!account.get('relationship')) {
      // Wait until the relationship is loaded
      actionBtn = '';
    } else if (account.getIn(['relationship', 'requested'])) {
      actionBtn = (
        <Button
          text={intl.formatMessage(messages.cancel_follow_request)}
          title={intl.formatMessage(messages.requested)}
          onClick={handleFollow}
        />
      );
    } else if (account.getIn(['relationship', 'muting'])) {
      actionBtn = (
        <Button
          text={intl.formatMessage(messages.unmute)}
          onClick={handleMute}
        />
      );
    } else if (!account.getIn(['relationship', 'blocking'])) {
      actionBtn = (
        <Button
          disabled={account.relationship?.blocked_by}
          className={classNames({
            'button--destructive': account.getIn(['relationship', 'following']),
          })}
          text={intl.formatMessage(
            account.getIn(['relationship', 'following'])
              ? messages.unfollow
              : messages.follow,
          )}
          onClick={handleFollow}
        />
      );
    } else if (account.getIn(['relationship', 'blocking'])) {
      actionBtn = (
        <Button
          text={intl.formatMessage(messages.unblock)}
          onClick={handleBlock}
        />
      );
    }
  } else {
    actionBtn = (
      <Button
        text={intl.formatMessage(messages.edit_profile)}
        onClick={handleEditProfile}
      />
    );
  }

  return (
    <div className='account-card'>
      <Link to={`/@${account.get('acct')}`} className='account-card__permalink'>
        <div className='account-card__header'>
          <img
            src={
              autoPlayGif ? account.get('header') : account.get('header_static')
            }
            alt=''
          />
        </div>

        <div className='account-card__title'>
          <div className='account-card__title__avatar'>
            <Avatar account={account as Account} size={56} />
          </div>
          <DisplayName account={account as Account} />
        </div>
      </Link>

      {account.get('note').length > 0 && (
        <div
          className='account-card__bio translate'
          onMouseEnter={handleMouseEnter}
          onMouseLeave={handleMouseLeave}
          dangerouslySetInnerHTML={{ __html: account.get('note_emojified') }}
        />
      )}

      <div className='account-card__actions'>
        <div className='account-card__counters'>
          <div className='account-card__counters__item'>
            <ShortNumber value={account.get('statuses_count')} />
            <small>
              <FormattedMessage id='account.posts' defaultMessage='Posts' />
            </small>
          </div>

          <div className='account-card__counters__item'>
            <ShortNumber value={account.get('followers_count')} />{' '}
            <small>
              <FormattedMessage
                id='account.followers'
                defaultMessage='Followers'
              />
            </small>
          </div>

          <div className='account-card__counters__item'>
            <ShortNumber value={account.get('following_count')} />{' '}
            <small>
              <FormattedMessage
                id='account.following'
                defaultMessage='Following'
              />
            </small>
          </div>
        </div>

        <div className='account-card__actions__button'>{actionBtn}</div>
      </div>
    </div>
  );
};
