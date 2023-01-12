import React, { useCallback } from 'react';
import { FormattedMessage } from 'react-intl';
import { useDispatch } from 'react-redux';
import { registrationsOpen } from 'mastodon/initial_state';
import { openModal } from 'mastodon/actions/modal';

const SignInBanner = () => {
  const dispatch = useDispatch();

  const openClosedRegistrationsModal = useCallback(
    () => dispatch(openModal('CLOSED_REGISTRATIONS')),
    [dispatch],
  );

  let signupButton;

  if (registrationsOpen) {
    signupButton = (
      <a href='/auth/sign_up' className='button button--block button-tertiary'>
        <FormattedMessage id='sign_in_banner.create_account' defaultMessage='Create account' />
      </a>
    );
  } else {
    signupButton = (
      <button className='button button--block button-tertiary' onClick={openClosedRegistrationsModal}>
        <FormattedMessage id='sign_in_banner.create_account' defaultMessage='Create account' />
      </button>
    );
  }

  return (
    <div className='sign-in-banner'>
      <p><FormattedMessage id='sign_in_banner.text' defaultMessage='Sign in to follow profiles or hashtags, favourite, share and reply to posts, or interact from your account on a different server.' /></p>
      <div className='hello-container'>
        <a className='button button--block button-openid_connect hello-btn' rel='nofollow' data-method='post' href='/auth/auth/openid_connect'>ō&nbsp;&nbsp;&nbsp;Login with Hellō</a>
      </div>
      {signupButton}
    </div>
  );
};

export default SignInBanner;
