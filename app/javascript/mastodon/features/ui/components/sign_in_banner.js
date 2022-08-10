import React from 'react';
import { FormattedMessage } from 'react-intl';

const SignInBanner = () => (
  <div className='sign-in-banner'>
    <p><FormattedMessage id='sign_in_banner.text' defaultMessage='Sign in to follow profiles or hashtags, favourite, share and reply to posts, or interact from your account on a different server.' /></p>
    <a href='/auth/sign_in' className='button button--block'><FormattedMessage id='sign_in_banner.sign_in' defaultMessage='Sign in' /></a>
  </div>
);

export default SignInBanner;
