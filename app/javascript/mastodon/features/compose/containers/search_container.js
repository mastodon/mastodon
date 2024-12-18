import { createSelector } from '@reduxjs/toolkit';
import { connect } from 'react-redux';

import {
  changeSearch,
  clearSearch,
  submitSearch,
  showSearch,
  openURL,
  clickSearchResult,
  forgetSearchResult,
} from 'mastodon/actions/search';

import Search from '../components/search';

const getRecentSearches = createSelector(
  state => state.getIn(['search', 'recent']),
  recent => recent.reverse(),
);

const mapStateToProps = state => ({
  value: state.getIn(['search', 'value']),
  submitted: state.getIn(['search', 'submitted']),
  recent: getRecentSearches(state),
});

const mapDispatchToProps = dispatch => ({

  onChange (value) {
    dispatch(changeSearch(value));
  },

  onClear () {
    dispatch(clearSearch());
  },

  onSubmit (type) {
    dispatch(submitSearch(type));
  },

  onShow () {
    dispatch(showSearch());
  },

  onOpenURL (q, routerHistory) {
    dispatch(openURL(q, routerHistory));
  },

  onClickSearchResult (q, type) {
    dispatch(clickSearchResult(q, type));
  },

  onForgetSearchResult (q) {
    dispatch(forgetSearchResult(q));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(Search);
