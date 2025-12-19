import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { DisplayName } from '@/mastodon/components/display_name';
import { IconLogo } from '@/mastodon/components/logo';
import { useAppSelector } from '@/mastodon/store';

import { AnnualReport, accountSelector } from './index';
import classes from './shared_page.module.scss';

export const WrapstodonSharedPage: FC = () => {
  const account = useAppSelector(accountSelector);
  const domain = useAppSelector((state) => state.meta.get('domain') as string);
  return (
    <main className={classes.wrapper}>
      <AnnualReport />
      <footer className={classes.footer}>
        <div className={classes.footerSection}>
          <IconLogo className={classes.logo} />
          <FormattedMessage
            id='annual_report.shared_page.footer'
            defaultMessage='Generated with {heart} by the Mastodon team'
            values={{ heart: '🐘' }}
            tagName='p'
          />
          <ul className={classes.linkList}>
            <li>
              <a href='https://joinmastodon.org'>
                <FormattedMessage
                  id='footer.about_mastodon'
                  defaultMessage='About Mastodon'
                />
              </a>
            </li>
            <li>
              <a href='https://joinmastodon.org/sponsors'>
                <FormattedMessage
                  id='annual_report.shared_page.donate'
                  defaultMessage='Donate'
                />
              </a>
            </li>
          </ul>
        </div>

        <div className={classes.footerSection}>
          <FormattedMessage
            id='annual_report.shared_page.footer_server_info'
            defaultMessage='{username} uses {domain}, one of many communities powered by Mastodon.'
            values={{
              username: <DisplayName variant='simple' account={account} />,
              domain: <strong>{domain}</strong>,
            }}
            tagName='p'
          />
          <a href='/about'>
            <FormattedMessage
              id='footer.about_server'
              defaultMessage='About {domain}'
              values={{ domain }}
            />
          </a>
        </div>
      </footer>
    </main>
  );
};
