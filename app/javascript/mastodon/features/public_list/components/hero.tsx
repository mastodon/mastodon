import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import { openModal } from 'mastodon/actions/modal';
import { apiFollowList } from 'mastodon/api/lists';
import { Button } from 'mastodon/components/button';
import { RelativeTimestamp } from 'mastodon/components/relative_timestamp';
import { AuthorLink } from 'mastodon/features/explore/components/author_link';
import { useIdentity } from 'mastodon/identity_context';
import { registrationsOpen, sso_redirect, me } from 'mastodon/initial_state';
import type { List } from 'mastodon/models/list';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

export const Hero: React.FC<{
  list: List;
}> = ({ list }) => {
  const { signedIn } = useIdentity();
  const dispatch = useAppDispatch();
  const signupUrl = useAppSelector(
    (state) =>
      state.server.getIn(['server', 'registrations', 'url'], null) ??
      '/auth/sign_up',
  ) as string;

  const handleClosedRegistrationsClick = useCallback(() => {
    dispatch(openModal({ modalType: 'CLOSED_REGISTRATIONS', modalProps: {} }));
  }, [dispatch]);

  const handleFollowAll = useCallback(() => {
    apiFollowList(list.id)
      .then(() => {
        // TODO
        return '';
      })
      .catch(() => {
        // TODO
      });
  }, [list]);

  let signUpButton;

  if (sso_redirect) {
    signUpButton = (
      <a href={sso_redirect} data-method='post' className='button'>
        <FormattedMessage id='' defaultMessage='Create account' />
      </a>
    );
  } else if (registrationsOpen) {
    signUpButton = (
      <a href={`${signupUrl}?list_id=${list.id}`} className='button'>
        <FormattedMessage id='' defaultMessage='Create account' />
      </a>
    );
  } else {
    signUpButton = (
      <Button onClick={handleClosedRegistrationsClick}>
        <FormattedMessage id='' defaultMessage='Create account' />
      </Button>
    );
  }

  return (
    <div className='lists__hero'>
      <div className='lists__hero__title'>
        <h1>{list.title}</h1>
        <p>
          {list.description.length > 0 ? (
            list.description
          ) : (
            <FormattedMessage id='' defaultMessage='No description given.' />
          )}
        </p>
      </div>

      <div className='lists__hero__meta'>
        <FormattedMessage
          id=''
          defaultMessage='Public list by {name}'
          values={{
            name: list.account_id && <AuthorLink accountId={list.account_id} />,
          }}
        >
          {(chunks) => (
            // eslint-disable-next-line react/jsx-no-useless-fragment
            <>{chunks}</>
          )}
        </FormattedMessage>

        <span aria-hidden>{' · '}</span>

        <FormattedMessage
          id=''
          defaultMessage='Created {timeAgo}'
          values={{
            timeAgo: (
              <RelativeTimestamp timestamp={list.created_at} short={false} />
            ),
          }}
        />
      </div>

      <div className='lists__hero__actions'>
        {!signedIn && signUpButton}
        {me !== list.account_id && (
          <Button onClick={handleFollowAll} secondary={!signedIn}>
            <FormattedMessage id='' defaultMessage='Follow all' />
          </Button>
        )}
        {me === list.account_id && (
          <Link className='button' to={`/lists/${list.id}/edit`}>
            <FormattedMessage id='' defaultMessage='Edit list' />
          </Link>
        )}
      </div>
    </div>
  );
};
