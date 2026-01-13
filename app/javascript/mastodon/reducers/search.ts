import { createReducer, isAnyOf } from '@reduxjs/toolkit';

import type { ApiSearchType } from 'mastodon/api_types/search';
import type { RecentSearch, SearchResults } from 'mastodon/models/search';
import { createSearchResults } from 'mastodon/models/search';

import {
  updateSearchHistory,
  submitSearch,
  expandSearch,
} from '../actions/search';

interface State {
  recent: RecentSearch[];
  q: string;
  type?: ApiSearchType;
  loading: boolean;
  results?: SearchResults;
}

const initialState: State = {
  recent: [],
  q: '',
  type: undefined,
  loading: false,
  results: undefined,
};

export const searchReducer = createReducer(initialState, (builder) => {
  builder.addCase(submitSearch.fulfilled, (state, action) => {
    state.q = action.meta.arg.q;
    state.type = action.meta.arg.type;
    state.results = createSearchResults(action.payload);
    state.loading = false;
  });

  builder.addCase(expandSearch.fulfilled, (state, action) => {
    const type = action.meta.arg.type;
    const results = createSearchResults(action.payload);

    state.type = type;
    state.results = {
      accounts: state.results
        ? [...state.results.accounts, ...results.accounts]
        : results.accounts,
      statuses: state.results
        ? [...state.results.statuses, ...results.statuses]
        : results.statuses,
      hashtags: state.results
        ? [...state.results.hashtags, ...results.hashtags]
        : results.hashtags,
    };
    state.loading = false;
  });

  builder.addCase(updateSearchHistory, (state, action) => {
    state.recent = action.payload;
  });

  builder.addMatcher(
    isAnyOf(expandSearch.pending, submitSearch.pending),
    (state, action) => {
      state.type = action.meta.arg.type;
      state.loading = true;
      if (action.type === submitSearch.pending.type) {
        state.results = undefined;
      }
    },
  );

  builder.addMatcher(
    isAnyOf(expandSearch.rejected, submitSearch.rejected),
    (state) => {
      state.loading = false;
    },
  );
});
