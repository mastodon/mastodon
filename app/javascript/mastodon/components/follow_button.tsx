import { useCallback, useEffect } from 'react';

import { useIntl, defineMessages } from 'react-intl';

import { useIdentity } from '@/mastodon/identity_context';
import { fetchRelationships, followAccount } from 'mastodon/actions/accounts';
import { openModal } from 'mastodon/actions/modal';
import { Button } from 'mastodon/components/button';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { me } from 'mastodon/initial_state';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

const messages = defineMessages({
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  followBack: { id: 'account.follow_back', defaultMessage: 'Follow back' },
  mutual: { id: 'account.mutual', defaultMessage: 'Mutual' },
  edit_profile: { id: 'account.edit_profile', defaultMessage: 'Edit profile' },
});

export const FollowButton: React.FC<{
  accountId?: string;
}> = ({ accountId }) => {
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
            type: 'follow',
            accountId: accountId,
            url: account?.url,
          },
        }),
      );
    }

    if (!relationship) return;

    if (accountId === me) {
      return;
    } else if (account && (relationship.following || relationship.requested)) {
      dispatch(
        openModal({ modalType: 'CONFIRM_UNFOLLOW', modalProps: { account } }),
      );
    } else {
      dispatch(followAccount(accountId));
    }
  }, [dispatch, accountId, relationship, account, signedIn]);

  let label;

  if (!signedIn) {
    label = intl.formatMessage(messages.follow);
  } else if (accountId === me) {
    label = intl.formatMessage(messages.edit_profile);
  } else if (!relationship) {
    label = <LoadingIndicator />;
  } else if (relationship.following && relationship.followed_by) {
    label = intl.formatMessage(messages.mutual);
  } else if (relationship.following || relationship.requested) {
    label = intl.formatMessage(messages.unfollow);
  } else if (relationship.followed_by) {
    label = intl.formatMessage(messages.followBack);
  } else {
    label = intl.formatMessage(messages.follow);
  }

  if (accountId === me) {
    return (
      <a
        href='/settings/profile'
        target='_blank'
        rel='noopener'
        className='button button-secondary'
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
        relationship?.blocking ||
        (!(relationship?.following || relationship?.requested) &&
          (account?.suspended || !!account?.moved))
      }
      secondary={following}
      className={following ? 'button--destructive' : undefined}
    >
      {label}
    </Button>
  );
};
