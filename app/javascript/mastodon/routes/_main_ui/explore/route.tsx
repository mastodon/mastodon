import { useCallback, useRef } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';

import { createFileRoute, Link, Outlet } from '@tanstack/react-router';

import { Column } from '@/mastodon/components/column';
import type { ColumnRef } from '@/mastodon/components/column';
import { ColumnHeader } from '@/mastodon/components/column_header';
import { SymbolLogo } from '@/mastodon/components/logo';
import { Search } from '@/mastodon/features/compose/components/search';
import { useBreakpoint } from '@/mastodon/features/ui/hooks/useBreakpoint';
import { useIdentity } from '@/mastodon/identity_context';
import TrendingUpIcon from '@/material-icons/400-24px/trending_up.svg?react';

const messages = defineMessages({
  title: { id: 'explore.title', defaultMessage: 'Trending' },
});

const Explore: React.FC<{ multiColumn?: boolean }> = ({ multiColumn }) => {
  const { signedIn } = useIdentity();
  const intl = useIntl();
  const columnRef = useRef<ColumnRef>(null);
  const logoRequired = useBreakpoint('full');

  const handleHeaderClick = useCallback(() => {
    columnRef.current?.scrollTop();
  }, []);

  return (
    <Column
      bindToDocument={!multiColumn}
      ref={columnRef}
      label={intl.formatMessage(messages.title)}
    >
      <ColumnHeader
        icon={'explore'}
        iconComponent={logoRequired ? SymbolLogo : TrendingUpIcon}
        title={intl.formatMessage(messages.title)}
        onClick={handleHeaderClick}
        multiColumn={multiColumn}
      />

      <div className='explore__search-header'>
        <Search singleColumn />
      </div>

      <div className='account__section-headline'>
        <Link to='/explore' activeOptions={{ exact: true }}>
          <FormattedMessage
            tagName='div'
            id='explore.trending_statuses'
            defaultMessage='Posts'
          />
        </Link>

        <Link to='/explore/tags' activeOptions={{ exact: true }}>
          <FormattedMessage
            tagName='div'
            id='explore.trending_tags'
            defaultMessage='Hashtags'
          />
        </Link>

        {signedIn && (
          <Link to='/explore/suggestions' activeOptions={{ exact: true }}>
            <FormattedMessage
              tagName='div'
              id='explore.suggested_follows'
              defaultMessage='People'
            />
          </Link>
        )}

        <Link to='/explore/links' activeOptions={{ exact: true }}>
          <FormattedMessage
            tagName='div'
            id='explore.trending_links'
            defaultMessage='News'
          />
        </Link>
      </div>

      <Outlet />

      <Helmet>
        <title>{intl.formatMessage(messages.title)}</title>
        <meta name='robots' content='all' />
      </Helmet>
    </Column>
  );
};

export const Route = createFileRoute('/_main_ui/explore')({
  component: Explore,
});
