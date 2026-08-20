import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { NavLink, Switch, Route } from 'react-router-dom';

import { Helmet } from '@unhead/react/helmet';

import { Column } from '@/mastodon/components/column';
import { ColumnHeader } from '@/mastodon/components/column/header';
import { isRedesignEnabled } from '@/mastodon/utils/environment';
import TrendingUpIcon from '@/material-icons/400-24px/trending_up.svg?react';
import { SymbolLogo } from 'mastodon/components/logo';
import { Search } from 'mastodon/features/compose/components/search';
import { useBreakpoint } from 'mastodon/features/ui/hooks/useBreakpoint';
import { useIdentity } from 'mastodon/identity_context';

import Links from './links';
import redesignClasses from './redesign.module.scss';
import Statuses from './statuses';
import Suggestions from './suggestions';
import Tags from './tags';

const messages = defineMessages({
  title: { id: 'explore.title', defaultMessage: 'Trending' },
});

const Explore: React.FC<{ multiColumn: boolean }> = ({ multiColumn }) => {
  const { signedIn } = useIdentity();
  const intl = useIntl();
  const logoRequired = useBreakpoint('full');

  return (
    <Column
      bindToDocument={!multiColumn}
      label={intl.formatMessage(messages.title)}
    >
      <ColumnHeader
        icon={'explore'}
        iconComponent={logoRequired ? SymbolLogo : TrendingUpIcon}
        title={intl.formatMessage(messages.title)}
        multiColumn={multiColumn}
        scrollTopOnClick
      />

      <div
        className={classNames(
          'explore__search-header',
          isRedesignEnabled() && redesignClasses.searchHeader,
        )}
      >
        <Search singleColumn />
      </div>

      <div className='account__section-headline'>
        <NavLink exact to='/explore'>
          <FormattedMessage
            tagName='div'
            id='explore.trending_statuses'
            defaultMessage='Posts'
          />
        </NavLink>

        <NavLink exact to='/explore/tags'>
          <FormattedMessage
            tagName='div'
            id='explore.trending_tags'
            defaultMessage='Hashtags'
          />
        </NavLink>

        {signedIn && (
          <NavLink exact to='/explore/suggestions'>
            <FormattedMessage
              tagName='div'
              id='explore.suggested_follows'
              defaultMessage='People'
            />
          </NavLink>
        )}

        <NavLink exact to='/explore/links'>
          <FormattedMessage
            tagName='div'
            id='explore.trending_links'
            defaultMessage='News'
          />
        </NavLink>
      </div>

      <Switch>
        <Route path='/explore/tags' component={Tags} />
        <Route path='/explore/links' component={Links} />
        <Route path='/explore/suggestions' component={Suggestions} />
        <Route exact path={['/explore', '/explore/posts']}>
          <Statuses multiColumn={multiColumn} />
        </Route>
      </Switch>

      <Helmet>
        <title>{intl.formatMessage(messages.title)}</title>
        <meta name='robots' content='all' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default Explore;
