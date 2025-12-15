import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { IconLogo } from '@/mastodon/components/logo';
import { useAppSelector } from '@/mastodon/store';

import { AnnualReport } from './index';
import classes from './shared_page.module.scss';

export const WrapstodonSharedPage: FC = () => {
  const isLoggedIn = useAppSelector((state) => !!state.meta.get('me'));
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
          {!isLoggedIn && (
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
