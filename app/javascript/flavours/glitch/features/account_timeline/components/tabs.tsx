import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import type { NavLinkProps } from 'react-router-dom';
import { NavLink } from 'react-router-dom';

import { useAccount } from '@/flavours/glitch/hooks/useAccount';
import { useAccountId } from '@/flavours/glitch/hooks/useAccountId';

import { isRedesignEnabled } from '../common';

import classes from './redesign.module.scss';

export const AccountTabs: FC<{ acct: string }> = ({ acct }) => {
  if (isRedesignEnabled()) {
    return <RedesignTabs />;
  }
  return (
    <div className='account__section-headline'>
      <NavLink exact to={`/@${acct}/featured`}>
        <FormattedMessage id='account.featured' defaultMessage='Featured' />
      </NavLink>
      <NavLink exact to={`/@${acct}`}>
        <FormattedMessage id='account.posts' defaultMessage='Posts' />
      </NavLink>
      <NavLink exact to={`/@${acct}/with_replies`}>
        <FormattedMessage
          id='account.posts_with_replies'
          defaultMessage='Posts and replies'
        />
      </NavLink>
      <NavLink exact to={`/@${acct}/media`}>
        <FormattedMessage id='account.media' defaultMessage='Media' />
      </NavLink>
    </div>
  );
};

const isActive: Required<NavLinkProps>['isActive'] = (match, location) =>
  match?.url === location.pathname ||
  (!!match?.url && location.pathname.startsWith(`${match.url}/tagged/`));

const RedesignTabs: FC = () => {
  const accountId = useAccountId();
  const account = useAccount(accountId);

  if (!account) {
    return null;
  }

  const { acct, show_featured, show_media } = account;

  return (
    <div className={classes.tabs}>
      <NavLink isActive={isActive} to={`/@${acct}`}>
        <FormattedMessage id='account.activity' defaultMessage='Activity' />
      </NavLink>
      {show_media && (
        <NavLink exact to={`/@${acct}/media`}>
          <FormattedMessage id='account.media' defaultMessage='Media' />
        </NavLink>
      )}
      {show_featured && (
        <NavLink exact to={`/@${acct}/featured`}>
          <FormattedMessage id='account.featured' defaultMessage='Featured' />
        </NavLink>
      )}
    </div>
  );
};
