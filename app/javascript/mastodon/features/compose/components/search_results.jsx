import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import FindInPageIcon from '@/material-icons/400-24px/find_in_page.svg?react';
import PeopleIcon from '@/material-icons/400-24px/group.svg?react';
import TagIcon from '@/material-icons/400-24px/tag.svg?react';
import { expandSearch } from 'mastodon/actions/search';
import { Icon }  from 'mastodon/components/icon';
import { LoadMore } from 'mastodon/components/load_more';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { SearchSection } from 'mastodon/features/explore/components/search_section';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import { ImmutableHashtag as Hashtag } from '../../../components/hashtag';
import AccountContainer from '../../../containers/account_container';
import StatusContainer from '../../../containers/status_container';

const INITIAL_PAGE_LIMIT = 10;

const withoutLastResult = list => {
  if (list.size > INITIAL_PAGE_LIMIT && list.size % INITIAL_PAGE_LIMIT === 1) {
    return list.skipLast(1);
  } else {
    return list;
  }
};

export const SearchResults = () => {
  const results = useAppSelector((state) => state.getIn(['search', 'results']));
  const isLoading = useAppSelector((state) => state.getIn(['search', 'isLoading']));

  const dispatch = useAppDispatch();

  const handleLoadMoreAccounts = useCallback(() => {
    dispatch(expandSearch('accounts'));
  }, [dispatch]);

  const handleLoadMoreStatuses = useCallback(() => {
    dispatch(expandSearch('statuses'));
  }, [dispatch]);

  const handleLoadMoreHashtags = useCallback(() => {
    dispatch(expandSearch('hashtags'));
  }, [dispatch]);

  let accounts, statuses, hashtags;

  if (results.get('accounts') && results.get('accounts').size > 0) {
    accounts = (
      <SearchSection title={<><Icon id='users' icon={PeopleIcon} /><FormattedMessage id='search_results.accounts' defaultMessage='Profiles' /></>}>
        {withoutLastResult(results.get('accounts')).map(accountId => <AccountContainer key={accountId} id={accountId} />)}
        {(results.get('accounts').size > INITIAL_PAGE_LIMIT && results.get('accounts').size % INITIAL_PAGE_LIMIT === 1) && <LoadMore visible onClick={handleLoadMoreAccounts} />}
      </SearchSection>
    );
  }

  if (results.get('hashtags') && results.get('hashtags').size > 0) {
    hashtags = (
      <SearchSection title={<><Icon id='hashtag' icon={TagIcon} /><FormattedMessage id='search_results.hashtags' defaultMessage='Hashtags' /></>}>
        {withoutLastResult(results.get('hashtags')).map(hashtag => <Hashtag key={hashtag.get('name')} hashtag={hashtag} />)}
        {(results.get('hashtags').size > INITIAL_PAGE_LIMIT && results.get('hashtags').size % INITIAL_PAGE_LIMIT === 1) && <LoadMore visible onClick={handleLoadMoreHashtags} />}
      </SearchSection>
    );
  }

  if (results.get('statuses') && results.get('statuses').size > 0) {
    statuses = (
      <SearchSection title={<><Icon id='quote-right' icon={FindInPageIcon} /><FormattedMessage id='search_results.statuses' defaultMessage='Posts' /></>}>
        {withoutLastResult(results.get('statuses')).map(statusId => <StatusContainer key={statusId} id={statusId} />)}
        {(results.get('statuses').size > INITIAL_PAGE_LIMIT && results.get('statuses').size % INITIAL_PAGE_LIMIT === 1) && <LoadMore visible onClick={handleLoadMoreStatuses} />}
      </SearchSection>
    );
  }

  return (
    <div className='search-results'>
      {!accounts && !hashtags && !statuses && (
        isLoading ? (
          <LoadingIndicator />
        ) : (
          <div className='empty-column-indicator'>
            <FormattedMessage id='search_results.nothing_found' defaultMessage='Could not find anything for these search terms' />
          </div>
        )
      )}
      {accounts}
      {hashtags}
      {statuses}
    </div>
  );

};
