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

const mapStateToProps = state => ({
  value: state.getIn(['search', 'value']),
  submitted: state.getIn(['search', 'submitted']),
  recent: state.getIn(['search', 'recent']),
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
