import type { FC } from 'react';

import { IconLogo } from '@/mastodon/components/logo';

import { AnnualReport } from './index';
import classes from './shared_page.module.css';

export const WrapstodonSharedPage: FC = () => {
  return (
    <main className={classes.wrapper}>
      <AnnualReport />
      <footer className={classes.footer}>
        <IconLogo className={classes.logo} />
        Generated with ♥ by the Mastodon team
      </footer>
    </main>
  );
};
