import { useCallback } from 'react';
import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import {
  authorizeFollowRequest,
  rejectFollowRequest,
} from '@/mastodon/actions/accounts';
import { useAccountVisibility } from '@/mastodon/hooks/useAccountVisibility';
import { useRelationship } from '@/mastodon/hooks/useRelationship';
import type { Account } from '@/mastodon/models/account';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import CheckIcon from '@/material-icons/400-24px/check.svg?react';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';

import { AvatarOverlay } from '../avatar_overlay';
import { Button } from '../button';
import { DisplayName } from '../display_name';
import { Icon } from '../icon';

export const AccountBanners: FC<{ account: Account }> = ({ account }) => {
  const { suspended, hidden } = useAccountVisibility(account.id);
  const relationship = useRelationship(account.id);

  if (hidden) {
    return null;
  }

  if (account.memorial) {
    return (
      <div className='account-memorial-banner'>
        <div className='account-memorial-banner__message'>
          <FormattedMessage
            id='account.in_memoriam'
            defaultMessage='In Memoriam.'
          />
        </div>
      </div>
    );
  }

  if (account.moved) {
    return <MovedNote account={account} targetAccountId={account.moved} />;
  }

  if (!suspended && relationship?.requested_by) {
    return <FollowRequestNote account={account} />;
  }

  return null;
};

const FollowRequestNote: FC<{ account: Account }> = ({ account }) => {
  const accountId = account.id;
  const dispatch = useAppDispatch();
  const handleAuthorize = useCallback(() => {
    dispatch(authorizeFollowRequest(accountId));
  }, [accountId, dispatch]);
  const handleReject = useCallback(() => {
    dispatch(rejectFollowRequest(accountId));
  }, [accountId, dispatch]);

  return (
    <div className='follow-request-banner'>
      <div className='follow-request-banner__message'>
        <FormattedMessage
          id='account.requested_follow'
          defaultMessage='{name} has requested to follow you'
          values={{ name: <DisplayName account={account} variant='simple' /> }}
        />
      </div>

      <div className='follow-request-banner__action'>
        <Button secondary onClick={handleAuthorize}>
          <Icon id='check' icon={CheckIcon} />
          <FormattedMessage
            id='follow_request.authorize'
            defaultMessage='Authorize'
          />
        </Button>

        <Button secondary onClick={handleReject}>
          <Icon id='times' icon={CloseIcon} />
          <FormattedMessage
            id='follow_request.reject'
            defaultMessage='Reject'
          />
        </Button>
      </div>
    </div>
  );
};

const MovedNote: React.FC<{
  account: Account;
  targetAccountId: string;
}> = ({ account: from, targetAccountId }) => {
  const to = useAppSelector((state) => state.accounts.get(targetAccountId));

  return (
    <div className='moved-account-banner'>
      <div className='moved-account-banner__message'>
        <FormattedMessage
          id='account.moved_to'
          defaultMessage='{name} has indicated that their new account is now:'
          values={{
            name: <DisplayName account={from} variant='simple' />,
          }}
        />
      </div>

      <div className='moved-account-banner__action'>
        <Link to={`/@${to?.acct}`} className='detailed-status__display-name'>
          <div className='detailed-status__display-avatar'>
            <AvatarOverlay account={to} friend={from} />
          </div>
          <DisplayName account={to} />
        </Link>

        <Link to={`/@${to?.acct}`} className='button'>
          <FormattedMessage
            id='account.go_to_profile'
            defaultMessage='Go to profile'
          />
        </Link>
      </div>
    </div>
  );
};
