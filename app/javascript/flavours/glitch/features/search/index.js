import React from 'react';
import SearchContainer from 'flavours/glitch/features/compose/containers/search_container';
import SearchResultsContainer from 'flavours/glitch/features/compose/containers/search_results_container';

const Search = () => (
  <div className='column search-page'>
    <SearchContainer />

    <div className='drawer__pager'>
      <div className='drawer__inner darker'>
        <SearchResultsContainer />
      </div>
    </div>
  </div>
);

export default Search;
