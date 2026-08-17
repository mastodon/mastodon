import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import { domain, sso_redirect } from 'mastodon/initial_state';

import classes from '../styles.module.scss';

export const Header = () => (
  <div className={classes.minimalHeader}>
    <div className={classes.leftSide}>
      <Link to='/overview'>{domain}</Link>
    </div>

    <div className={classes.rightSide}>
      <a
        href={sso_redirect ?? '/auth/sign_in'}
        data-method={sso_redirect ? 'post' : undefined}
        className='button button-secondary'
      >
        <FormattedMessage id='sign_in_banner.sign_in' defaultMessage='Login' />
      </a>
    </div>
  </div>
);
