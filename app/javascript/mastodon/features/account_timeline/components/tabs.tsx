import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import type { NavLinkProps } from 'react-router-dom';
import { NavLink } from 'react-router-dom';

import { useLayout } from '@/mastodon/hooks/useLayout';

import { isRedesignEnabled } from '../common';

import classes from './redesign.module.scss';

export const AccountTabs: FC<{ acct: string }> = ({ acct }) => {
  const { layout } = useLayout();
  if (isRedesignEnabled()) {
    return (
      <div className={classes.tabs}>
        {layout !== 'single-column' && (
          <NavLink exact to={`/@${acct}/about`}>
            <FormattedMessage id='account.about' defaultMessage='About' />
          </NavLink>
        )}
        <NavLink isActive={isActive} to={`/@${acct}/posts`}>
          <FormattedMessage id='account.activity' defaultMessage='Activity' />
        </NavLink>
        <NavLink exact to={`/@${acct}/media`}>
          <FormattedMessage id='account.media' defaultMessage='Media' />
        </NavLink>
        <NavLink exact to={`/@${acct}/featured`}>
          <FormattedMessage id='account.featured' defaultMessage='Featured' />
        </NavLink>
      </div>
    );
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
