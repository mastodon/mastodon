import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { IconLogo } from '@/mastodon/components/logo';

import { AnnualReport } from './index';
import classes from './shared_page.module.css';

export const WrapstodonSharedPage: FC = () => {
  return (
    <main className={classes.wrapper}>
      <AnnualReport />
      <footer className={classes.footer}>
        <IconLogo className={classes.logo} />
        <FormattedMessage
          id='annual_report.shared_page.footer'
          defaultMessage='Generated with {heart} by the Mastodon team'
          values={{ heart: '♥' }}
        />
      </footer>
    </main>
  );
};
