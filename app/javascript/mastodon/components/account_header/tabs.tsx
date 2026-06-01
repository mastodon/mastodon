import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import type { NavLinkProps } from 'react-router-dom';

import { useAccount } from '@/mastodon/hooks/useAccount';
import { useAccountId } from '@/mastodon/hooks/useAccountId';

import { TabLink, TabList } from '../tab_list';

import classes from './styles.module.scss';

const isActive: Required<NavLinkProps>['isActive'] = (match, location) =>
  match?.url === location.pathname ||
  (!!match?.url && location.pathname.startsWith(`${match.url}/tagged/`));

export const AccountTabs: FC = () => {
  const accountId = useAccountId();
  const account = useAccount(accountId);

  if (!account) {
    return <hr className={classes.noTabs} />;
  }

  const { acct, show_featured, show_media } = account;
  if (!show_featured && !show_media) {
    return <hr className={classes.noTabs} />;
  }

  return (
    <TabList>
      <TabLink isActive={isActive} to={`/@${acct}`}>
        <FormattedMessage id='account.activity' defaultMessage='Activity' />
      </TabLink>
      {show_media && (
        <TabLink exact to={`/@${acct}/media`}>
          <FormattedMessage id='account.media' defaultMessage='Media' />
        </TabLink>
      )}
      {show_featured && (
        <TabLink exact to={`/@${acct}/featured`}>
          <FormattedMessage id='account.featured' defaultMessage='Featured' />
        </TabLink>
      )}
    </TabList>
  );
};
