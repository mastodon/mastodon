import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import { domain, termsOfServiceEnabled } from '@/mastodon/initial_state';

import classes from './footer_links.module.scss';

export const NavigationFooterLinks: React.FC<{ siteName?: string }> = ({
  siteName = domain,
}) => {
  return (
    <div className={classes.root}>
      <h2 className={classes.heading}>{siteName}</h2>
      <ul className={classes.list}>
        <li>
          <Link to='/about'>
            <FormattedMessage
              id='footer.about_this_server'
              defaultMessage='About'
            />
          </Link>
        </li>
        <li>
          <Link to='/privacy-policy' rel='privacy-policy'>
            <FormattedMessage
              id='footer.privacy_policy_short'
              defaultMessage='Privacy'
            />
          </Link>
        </li>
        {termsOfServiceEnabled && (
          <li>
            <Link to='/terms-of-service' rel='terms-of-service'>
              <FormattedMessage
                id='footer.terms_of_service_short'
                defaultMessage='Terms'
              />
            </Link>
          </li>
        )}
      </ul>
    </div>
  );
};
