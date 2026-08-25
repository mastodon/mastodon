import type React from 'react';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import { IconLogo } from '@/mastodon/components/logo';
import { domain, title } from '@/mastodon/initial_state';
import { useAppSelector } from '@/mastodon/store';

import classes from './header.module.scss';

export const NavigationHeader: React.FC<{ siteName?: string }> = ({
  siteName,
}) => {
  const { item: server } = useAppSelector((state) => state.server.server);
  const appIconUrl = server?.icon[3]?.src;

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
