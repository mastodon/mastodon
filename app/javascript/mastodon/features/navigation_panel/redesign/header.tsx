import type React from 'react';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import { IconLogo } from '@/mastodon/components/logo';
import { domain } from '@/mastodon/initial_state';

import classes from './header.module.scss';

export const NavigationHeader: React.FC<{ siteName?: string }> = ({
  siteName = domain,
}) => {
  return (
    <header className={classes.root}>
      <Link to='/' className={classes.siteNameLink}>
        <span className={classes.serverName}>{siteName}</span>
        <span className={classes.poweredBy}>
          <FormattedMessage
            id='navigation_bar.powered_by_mastodon'
            defaultMessage='powered by {logo}Mastodon'
            values={{
              logo: <IconLogo role='presentation' />,
            }}
          />
        </span>
      </Link>
    </header>
  );
};
