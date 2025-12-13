import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { IconLogo } from '@/mastodon/components/logo';
import { me } from '@/mastodon/initial_state';

import { AnnualReport } from './index';
import classes from './shared_page.module.scss';

export const WrapstodonSharedPage: FC = () => {
  return (
    <main className={classes.wrapper}>
      <AnnualReport />
      <footer className={classes.footer}>
        <IconLogo className={classes.logo} />
        <FormattedMessage
          id='annual_report.shared_page.footer'
          defaultMessage='Generated with {heart} by the Mastodon team'
          values={{ heart: '🐘' }}
        />
        <nav className={classes.nav}>
          <a href='https://joinmastodon.org'>
            <FormattedMessage id='footer.about' defaultMessage='About' />
          </a>
          {!me && (
            <a href='https://joinmastodon.org/servers'>
              <FormattedMessage
                id='annual_report.shared_page.sign_up'
                defaultMessage='Sign up'
              />
            </a>
          )}
          <a href='https://joinmastodon.org/sponsors'>
            <FormattedMessage
              id='annual_report.shared_page.donate'
              defaultMessage='Donate'
            />
          </a>
        </nav>
      </footer>
    </main>
  );
};
