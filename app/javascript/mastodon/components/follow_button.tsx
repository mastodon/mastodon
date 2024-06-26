import { useCallback, useEffect } from 'react';

import { useIntl, defineMessages } from 'react-intl';

import {
  fetchRelationships,
  followAccount,
  unfollowAccount,
} from 'mastodon/actions/accounts';
import { Button } from 'mastodon/components/button';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { me } from 'mastodon/initial_state';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

const messages = defineMessages({
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  followBack: { id: 'account.follow_back', defaultMessage: 'Follow back' },
  mutual: { id: 'account.mutual', defaultMessage: 'Mutual' },
  cancel_follow_request: {
    id: 'account.cancel_follow_request',
    defaultMessage: 'Withdraw follow request',
  },
  edit_profile: { id: 'account.edit_profile', defaultMessage: 'Edit profile' },
});

export const FollowButton: React.FC<{
  accountId: string;
}> = ({ accountId }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const relationship = useAppSelector((state) =>
    state.relationships.get(accountId),
  );
  const following = relationship?.following || relationship?.requested;

  useEffect(() => {
    dispatch(fetchRelationships([accountId]));
  }, [dispatch, accountId]);

  const handleClick = useCallback(() => {
    if (!relationship) return;
    if (accountId === me) {
      return;
    } else if (relationship.following || relationship.requested) {
      dispatch(unfollowAccount(accountId));
    } else {
      dispatch(followAccount(accountId));
    }
  }, [dispatch, accountId, relationship]);

  let label;

  if (accountId === me) {
    label = intl.formatMessage(messages.edit_profile);
  } else if (!relationship) {
    label = <LoadingIndicator />;
  } else if (relationship.requested) {
    label = intl.formatMessage(messages.cancel_follow_request);
  } else if (relationship.following && relationship.followed_by) {
    label = intl.formatMessage(messages.mutual);
  } else if (!relationship.following && relationship.followed_by) {
    label = intl.formatMessage(messages.followBack);
  } else if (relationship.following) {
    label = intl.formatMessage(messages.unfollow);
  } else {
    label = intl.formatMessage(messages.follow);
  }

  if (accountId === me) {
    return (
      <a
        href='/settings/profile'
        target='_blank'
        rel='noreferrer noopener'
        className='button button-secondary'
      >
        {label}
      </a>
    );
  }

  return (
    <Button
      onClick={handleClick}
      disabled={relationship?.blocked_by || relationship?.blocking}
      secondary={following}
      className={following ? 'button--destructive' : undefined}
    >
      {label}
    </Button>
  );
};
