import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { openModal } from '@/mastodon/actions/modal';
import { Button } from '@/mastodon/components/button';
import { registrationsOpen, sso_redirect } from '@/mastodon/initial_state';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import classes from './styles.module.scss';

/**
 * Shown at the end of the first page of a public feed when the server limits
 * logged-out visitors to that first page.
 */
export const LoggedOutFeedLimit: React.FC = () => {
  const dispatch = useAppDispatch();
  const signupUrl = useAppSelector(
    (state) => state.server.server.item?.registrations.url ?? '/auth/sign_up',
  );

  const handleClosedRegistrationsClick = useCallback(() => {
    dispatch(openModal({ modalType: 'CLOSED_REGISTRATIONS', modalProps: {} }));
  }, [dispatch]);

  const createAccountLabel = (
    <FormattedMessage
      id='sign_in_banner.create_account'
      defaultMessage='Create account'
    />
  );

  let signupButton;

  if (sso_redirect) {
    signupButton = (
      <Button as='a' href={sso_redirect} data-method='post' color='accent'>
        {createAccountLabel}
      </Button>
    );
  } else if (registrationsOpen) {
    signupButton = (
      <Button as='a' href={signupUrl} color='accent'>
        {createAccountLabel}
      </Button>
    );
  } else {
    signupButton = (
      <Button onClick={handleClosedRegistrationsClick} color='accent'>
        {createAccountLabel}
      </Button>
    );
  }

  return (
    <div className={classes.wrapper}>
      <p className={classes.title}>
        <FormattedMessage
          id='logged_out_feed_limit.title'
          defaultMessage='Want to see more?'
        />
      </p>
      <p>
        <FormattedMessage
          id='logged_out_feed_limit.message'
          defaultMessage='Log in or create an account to keep scrolling.'
        />
      </p>
      <div className={classes.actions}>
        {signupButton}
        <Button
          as='a'
          href={sso_redirect ?? '/auth/sign_in'}
          data-method={sso_redirect ? 'post' : undefined}
          color='neutral'
          variant='tonal'
        >
          <FormattedMessage id='sign_in_banner.sign_in' defaultMessage='Login' />
        </Button>
      </div>
    </div>
  );
};
