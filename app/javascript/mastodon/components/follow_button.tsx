import { useCallback, useEffect } from 'react';

import { useIntl, defineMessages } from 'react-intl';

import classNames from 'classnames';
import { Link } from 'react-router-dom';

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
import { isRedesignEnabled } from '../utils/environment';

import { Button as RedesignButton } from './button/redesign';
import type { ButtonProps as RedesignButtonProps } from './button/redesign';
import type { MastodonLocationDescriptor } from './router';

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

interface FollowButtonOptions {
  accountId?: string;
  labelLength?: 'auto' | 'short' | 'long';
  withUnmute?: boolean;
  reference?: string;
}

interface FollowButtonReturn {
  label: React.ReactNode;
  onClick: (() => void) | undefined;
  link: MastodonLocationDescriptor | undefined;
  disabled: boolean;
  following: boolean;
  secondary: boolean;
  hidden: boolean;
}

export function useFollowButton({
  accountId,
  labelLength = 'auto',
  withUnmute = true,
  reference,
}: FollowButtonOptions): FollowButtonReturn {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const { signedIn } = useIdentity();
  const account = useAppSelector((state) =>
    accountId ? state.accounts.get(accountId) : undefined,
  );
  const relationship = useAppSelector((state) =>
    accountId ? state.relationships.get(accountId) : undefined,
  );
  const following = relationship?.following || relationship?.requested || false;
  const secondary = following || relationship?.blocking || false;
  const link = accountId === me ? '/profile/edit' : undefined;

  useEffect(() => {
    if (accountId && signedIn) {
      dispatch(fetchRelationships([accountId]));
    }
  }, [dispatch, accountId, signedIn]);

  const onClick = useCallback(() => {
    if (!signedIn) {
      dispatch(
        openModal({
          modalType: 'INTERACTION',
          modalProps: {
            intent: 'follow',
            accountId: accountId,
            url: account?.url,
          },
        }),
      );
    }

    if (!relationship || !accountId) return;

    if (accountId === me) {
      return;
    } else if (relationship.blocking) {
      dispatch(
        openModal({
          modalType: 'CONFIRM_UNBLOCK',
          modalProps: { account },
        }),
      );
    } else if (relationship.muting && withUnmute) {
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
    } else {
      // @ts-expect-error this action is not typed yet
      dispatch(followAccount(accountId, { ref: reference }));
    }
  }, [
    signedIn,
    relationship,
    accountId,
    withUnmute,
    account,
    dispatch,
    reference,
  ]);

  const isNarrow = useBreakpoint('narrow');
  const useShortLabel =
    labelLength === 'short' || (labelLength === 'auto' && isNarrow);
  const messages = useShortLabel ? shortMessages : longMessages;

  const followMessage = account?.locked
    ? messages.followRequest
    : messages.follow;

  let label: React.ReactNode;
  let disabled =
    relationship?.blocked_by || account?.suspended || !!account?.moved;

  if (!signedIn) {
    label = intl.formatMessage(followMessage);
  } else if (accountId === me) {
    label = intl.formatMessage(messages.editProfile);
  } else if (!relationship) {
    label = <LoadingIndicator />;
  } else if (relationship.muting && withUnmute) {
    label = intl.formatMessage(messages.unmute);
    disabled = false;
  } else if (relationship.following) {
    label = intl.formatMessage(messages.unfollow);
    disabled = false;
  } else if (relationship.blocking) {
    label = intl.formatMessage(messages.unblock);
    disabled = false;
  } else if (relationship.requested) {
    label = intl.formatMessage(messages.followRequestCancel);
    disabled = false;
  } else if (relationship.followed_by && !account?.locked) {
    label = intl.formatMessage(messages.followBack);
  } else {
    label = intl.formatMessage(followMessage);
  }

  const isMovedAndUnfollowedAccount =
    (account?.moved && !relationship?.following) || false;

  return {
    onClick,
    link,
    label,
    disabled,
    following,
    secondary,
    hidden: isMovedAndUnfollowedAccount,
  };
}

const FollowButtonLegacy: React.FC<
  FollowButtonOptions & {
    compact?: boolean;
    className?: string;
  }
> = ({ compact, className, ...props }) => {
  const { onClick, link, label, disabled, following, secondary } =
    useFollowButton(props);

  if (link) {
    const buttonClasses = classNames(className, 'button button-secondary', {
      'button--compact': compact,
    });

    return (
      <Link to='/profile/edit' className={buttonClasses}>
        {label}
      </Link>
    );
  }

  return (
    <Button
      onClick={onClick}
      disabled={disabled}
      secondary={secondary}
      compact={compact}
      className={classNames(className, { 'button--destructive': following })}
    >
      {label}
    </Button>
  );
};

const FollowButtonRedesign: React.FC<
  FollowButtonOptions &
    Pick<RedesignButtonProps, 'size' | 'color' | 'className'>
> = ({ accountId, labelLength, withUnmute, reference, ...buttonProps }) => {
  const { onClick, link, label, disabled, secondary, hidden } = useFollowButton(
    {
      accountId,
      labelLength,
      withUnmute,
      reference,
    },
  );

  if (hidden) {
    return null;
  }

  if (link) {
    return (
      <RedesignButton as='link' to={link} {...buttonProps}>
        {label}
      </RedesignButton>
    );
  }

  return (
    <RedesignButton
      {...buttonProps}
      onClick={onClick}
      disabled={disabled}
      variant={secondary ? 'tonal' : 'solid'}
    >
      {label}
    </RedesignButton>
  );
};

export const FollowButton: React.FC<
  FollowButtonOptions & {
    compact?: boolean;
    className?: string;
  }
> = ({ compact, ...props }) => {
  if (isRedesignEnabled()) {
    return <FollowButtonRedesign {...props} size={compact ? 'sm' : 'md'} />;
  }
  return <FollowButtonLegacy compact={compact} {...props} />;
};
