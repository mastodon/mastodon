import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import {
  authorizeFollowRequest,
  rejectFollowRequest,
} from 'mastodon/actions/accounts';
import { Icon } from 'mastodon/components/icon';
import { useAppDispatch } from 'mastodon/store';

interface Props {
  displayName: string;
  accountId: string;
}

export const FollowRequestNote = ({ displayName, accountId }: Props) => {
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
