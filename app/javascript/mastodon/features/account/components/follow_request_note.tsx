import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import {
  authorizeFollowRequest,
  rejectFollowRequest,
} from 'mastodon/actions/accounts';
import { Icon } from 'mastodon/components/icon';
import type { Account } from 'mastodon/reducers/accounts';
import { useAppDispatch } from 'mastodon/store';
import type { Map as TypeSafeImmutableMap } from 'mastodon/utils/immutable';

interface Props {
  account: TypeSafeImmutableMap<Account>;
}

export const FollowRequestNote = ({ account }: Props) => {
  const displayName = account.get('display_name_html');
  const accountId = account.get('id');
  const dispatch = useAppDispatch();

  const onAuthorize = useCallback(() => {
    dispatch(authorizeFollowRequest(accountId));
  }, [dispatch, accountId]);

  const onReject = useCallback(() => {
    dispatch(rejectFollowRequest(accountId));
  }, [dispatch, accountId]);

  return (
    <div className='follow-request-banner'>
      <div className='follow-request-banner__message'>
        <FormattedMessage
          id='account.requested_follow'
          defaultMessage='{name} has requested to follow you'
          values={{
            name: (
              <bdi>
                <strong dangerouslySetInnerHTML={{ __html: displayName }} />
              </bdi>
            ),
          }}
        />
      </div>

      <div className='follow-request-banner__action'>
        <button
          type='button'
          className='button button-tertiary button--confirmation'
          onClick={onAuthorize}
        >
          <Icon id='check' fixedWidth />
          <FormattedMessage
            id='follow_request.authorize'
            defaultMessage='Authorize'
          />
        </button>

        <button
          type='button'
          className='button button-tertiary button--destructive'
          onClick={onReject}
        >
          <Icon id='times' fixedWidth />
          <FormattedMessage
            id='follow_request.reject'
            defaultMessage='Reject'
          />
        </button>
      </div>
    </div>
  );
};
