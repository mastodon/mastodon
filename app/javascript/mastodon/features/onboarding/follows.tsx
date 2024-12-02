import { useEffect, useState, useCallback, useRef } from 'react';

import { FormattedMessage, useIntl, defineMessages } from 'react-intl';

import { Helmet } from 'react-helmet';
import { Link } from 'react-router-dom';

import { useDebouncedCallback } from 'use-debounce';

import PersonIcon from '@/material-icons/400-24px/person.svg?react';
import { fetchRelationships } from 'mastodon/actions/accounts';
import { importFetchedAccounts } from 'mastodon/actions/importer';
import { fetchSuggestions } from 'mastodon/actions/suggestions';
import { markAsPartial } from 'mastodon/actions/timelines';
import { apiRequest } from 'mastodon/api';
import type { ApiAccountJSON } from 'mastodon/api_types/accounts';
import Column from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import { ColumnSearchHeader } from 'mastodon/components/column_search_header';
import ScrollableList from 'mastodon/components/scrollable_list';
import Account from 'mastodon/containers/account_container';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

const messages = defineMessages({
  title: {
    id: 'onboarding.follows.title',
    defaultMessage: 'Follow people to get started',
  },
  search: { id: 'onboarding.follows.search', defaultMessage: 'Search' },
  back: { id: 'onboarding.follows.back', defaultMessage: 'Back' },
});

type Mode = 'remove' | 'add';

export const Follows: React.FC<{
  multiColumn?: boolean;
}> = ({ multiColumn }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const isLoading = useAppSelector((state) => state.suggestions.isLoading);
  const suggestions = useAppSelector((state) => state.suggestions.items);
  const [searchAccountIds, setSearchAccountIds] = useState<string[]>([]);
  const [mode, setMode] = useState<Mode>('remove');
  const [isLoadingSearch, setIsLoadingSearch] = useState(false);
  const [isSearching, setIsSearching] = useState(false);

  useEffect(() => {
    void dispatch(fetchSuggestions());

    return () => {
      dispatch(markAsPartial('home'));
    };
  }, [dispatch]);

  const handleSearchClick = useCallback(() => {
    setMode('add');
  }, [setMode]);

  const handleDismissSearchClick = useCallback(() => {
    setMode('remove');
    setIsSearching(false);
  }, [setMode, setIsSearching]);

  const searchRequestRef = useRef<AbortController | null>(null);

  const handleSearch = useDebouncedCallback(
    (value: string) => {
      if (searchRequestRef.current) {
        searchRequestRef.current.abort();
      }

      if (value.trim().length === 0) {
        setIsSearching(false);
        setSearchAccountIds([]);
        return;
      }

      setIsSearching(true);
      setIsLoadingSearch(true);

      searchRequestRef.current = new AbortController();

      void apiRequest<ApiAccountJSON[]>('GET', 'v1/accounts/search', {
        signal: searchRequestRef.current.signal,
        params: {
          q: value,
        },
      })
        .then((data) => {
          dispatch(importFetchedAccounts(data));
          dispatch(fetchRelationships(data.map((a) => a.id)));
          setSearchAccountIds(data.map((a) => a.id));
          setIsLoadingSearch(false);
          return '';
        })
        .catch(() => {
          setIsLoadingSearch(false);
        });
    },
    500,
    { leading: true, trailing: true },
  );

  let displayedAccountIds: string[];

  if (mode === 'add' && isSearching) {
    displayedAccountIds = searchAccountIds;
  } else {
    displayedAccountIds = suggestions.map(
      (suggestion) => suggestion.account_id,
    );
  }

  return (
    <Column
      bindToDocument={!multiColumn}
      label={intl.formatMessage(messages.title)}
    >
      <ColumnHeader
        title={intl.formatMessage(messages.title)}
        icon='person'
        iconComponent={PersonIcon}
        multiColumn={multiColumn}
        showBackButton
      />

      <ColumnSearchHeader
        placeholder={intl.formatMessage(messages.search)}
        onBack={handleDismissSearchClick}
        onActivate={handleSearchClick}
        active={mode === 'add'}
        onSubmit={handleSearch}
      />

      <ScrollableList
        scrollKey='follow_recommendations'
        trackScroll={!multiColumn}
        bindToDocument={!multiColumn}
        showLoading={
          (isLoading || isLoadingSearch) && displayedAccountIds.length === 0
        }
        hasMore={false}
        isLoading={isLoading || isLoadingSearch}
        footer={
          <>
            {displayedAccountIds.length > 0 && <div className='spacer' />}

            <div className='column-footer'>
              <Link className='button button--block' to='/home'>
                <FormattedMessage
                  id='onboarding.follows.done'
                  defaultMessage='Done'
                />
              </Link>
            </div>
          </>
        }
        emptyMessage={
          mode === 'remove' ? (
            <FormattedMessage
              id='onboarding.follows.empty'
              defaultMessage='Unfortunately, no results can be shown right now. You can try using search or browsing the explore page to find people to follow, or try again later.'
            />
          ) : (
            <FormattedMessage
              id='lists.no_results_found'
              defaultMessage='No results found.'
            />
          )
        }
      >
        {displayedAccountIds.map((accountId) => (
          <Account
            /* @ts-expect-error inferred props are wrong */
            id={accountId}
            key={accountId}
            withBio
          />
        ))}
      </ScrollableList>

      <Helmet>
        <title>{intl.formatMessage(messages.title)}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default Follows;
