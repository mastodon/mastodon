import React from 'react';
import SearchUsersContainer from 'mastodon/features/compose/containers/search_users_container';
import SearchUsersResultsContainer from 'mastodon/features/compose/containers/search_users_results_container';

const SearchUsers = () => (
  <div className='column'>
    <SearchUsersContainer />

    <div className='drawer__pager'>
      <div className='drawer__inner darker'>
        <SearchUsersResultsContainer />
      </div>
    </div>
  </div>
);

export default SearchUsers;
