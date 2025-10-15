import { useCallback, useEffect } from 'react';

import { useIntl, defineMessages } from 'react-intl';

import classNames from 'classnames';

import { useIdentity } from '@/mastodon/identity_context';
import {
  fetchRelationships,
  followAccount,
  unmuteAccount,
} from 'mastodon/actions/accounts';
import { openModal } from 'mastodon/actions/modal';
import { Button } from 'mastodon/components/button';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { me } from 'mastodon/initial_state';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import { useBreakpoint } from '../features/ui/hooks/useBreakpoint';

const longMessages = defineMessages({
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  unblock: { id: 'account.unblock_short', defaultMessage: 'Unblock' },
  unmute: { id: 'account.unmute_short', defaultMessage: 'Unmute' },
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  followBack: { id: 'account.follow_back', defaultMessage: 'Follow back' },
  followRequest: {
    id: 'account.follow_request',
    defaultMessage: 'Request to follow',
  },
  followRequestCancel: {
    id: 'account.follow_request_cancel',
    defaultMessage: 'Cancel request',
  },
  editProfile: { id: 'account.edit_profile', defaultMessage: 'Edit profile' },
});

const shortMessages = {
  ...longMessages, // Align type signature of shortMessages and longMessages
  ...defineMessages({
    followBack: {
      id: 'account.follow_back_short',
      defaultMessage: 'Follow back',
    },
    followRequest: {
      id: 'account.follow_request_short',
      defaultMessage: 'Request',
    },
    followRequestCancel: {
      id: 'account.follow_request_cancel_short',
      defaultMessage: 'Cancel',
    },
    editProfile: { id: 'account.edit_profile_short', defaultMessage: 'Edit' },
  }),
};

export const FollowButton: React.FC<{
  accountId?: string;
  compact?: boolean;
  labelLength?: 'auto' | 'short' | 'long';
  className?: string;
}> = ({ accountId, compact, labelLength = 'auto', className }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const { signedIn } = useIdentity();
  const account = useAppSelector((state) =>
    accountId ? state.accounts.get(accountId) : undefined,
  );
  const relationship = useAppSelector((state) =>
    accountId ? state.relationships.get(accountId) : undefined,
  );
  const following = relationship?.following || relationship?.requested;

  useEffect(() => {
    if (accountId && signedIn) {
      dispatch(fetchRelationships([accountId]));
    }
  }, [dispatch, accountId, signedIn]);

  const handleClick = useCallback(() => {
    if (!signedIn) {
      dispatch(
        openModal({
          modalType: 'INTERACTION',
          modalProps: {
            accountId: accountId,
            url: account?.url,
          },
        }),
      );
    }

    if (!relationship || !accountId) return;

    if (accountId === me) {
      return;
    } else if (relationship.muting) {
      dispatch(unmuteAccount(accountId));
    } else if (account && relationship.following) {
      dispatch(
        openModal({ modalType: 'CONFIRM_UNFOLLOW', modalProps: { account } }),
      );
    } else if (account && relationship.requested) {
      dispatch(
        openModal({
          modalType: 'CONFIRM_WITHDRAW_REQUEST',
          modalProps: { account },
        }),
      );
    } else if (relationship.blocking) {
      dispatch(
        openModal({
          modalType: 'CONFIRM_UNBLOCK',
          modalProps: { account },
        }),
      );
    } else {
      dispatch(followAccount(accountId));
    }
  }, [dispatch, accountId, relationship, account, signedIn]);

  const isNarrow = useBreakpoint('narrow');
  const useShortLabel =
    labelLength === 'short' || (labelLength === 'auto' && isNarrow);
  const messages = useShortLabel ? shortMessages : longMessages;

  const followMessage = account?.locked
    ? messages.followRequest
    : messages.follow;

  let label;

  if (!signedIn) {
    label = intl.formatMessage(followMessage);
  } else if (accountId === me) {
    label = intl.formatMessage(messages.editProfile);
  } else if (!relationship) {
    label = <LoadingIndicator />;
  } else if (relationship.muting) {
    label = intl.formatMessage(messages.unmute);
  } else if (relationship.following) {
    label = intl.formatMessage(messages.unfollow);
  } else if (relationship.blocking) {
    label = intl.formatMessage(messages.unblock);
  } else if (relationship.requested) {
    label = intl.formatMessage(messages.followRequestCancel);
  } else if (relationship.followed_by && !account?.locked) {
    label = intl.formatMessage(messages.followBack);
  } else {
    label = intl.formatMessage(followMessage);
  }

  if (accountId === me) {
    return (
      <a
        href='/settings/profile'
        target='_blank'
        rel='noopener'
        className={classNames(className, 'button button-secondary', {
          'button--compact': compact,
        })}
      >
        {label}
      </a>
    );
  }

  return (
    <Button
      onClick={handleClick}
      disabled={
        relationship?.blocked_by ||
        (!(relationship?.following || relationship?.requested) &&
          (account?.suspended || !!account?.moved))
      }
      secondary={following}
      compact={compact}
      className={classNames(className, { 'button--destructive': following })}
    >
      {label}
    </Button>
  );
};
