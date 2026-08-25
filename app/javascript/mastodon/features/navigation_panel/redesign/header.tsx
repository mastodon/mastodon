import type React from 'react';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import { IconLogo } from '@/mastodon/components/logo';
import { domain, title } from '@/mastodon/initial_state';

import classes from './header.module.scss';

export const NavigationHeader: React.FC<{ siteName?: string }> = ({
  siteName,
}) => {
  const appIconUrl = document
    .querySelector('link[rel="apple-touch-icon"][sizes="120x120"]')
    ?.getAttribute('href');

  return (
    <header className={classes.root}>
      <Link to='/' className={classes.siteNameLink}>
        {appIconUrl && (
          <img src={appIconUrl} alt='' className={classes.appIcon} />
        )}
        <span className={classes.content}>
          <span className={classes.serverName}>
            {siteName ?? title ?? domain}
          </span>
          <span className={classes.poweredBy}>
            <FormattedMessage
              id='navigation_bar.powered_by_mastodon'
              defaultMessage='powered by {logo}Mastodon'
              values={{
                logo: <IconLogo role='presentation' />,
              }}
            />
          </span>
        </span>
      </Link>
    </header>
  );
};
