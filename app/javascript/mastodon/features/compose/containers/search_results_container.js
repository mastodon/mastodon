import { connect } from 'react-redux';

import { expandSearch } from 'mastodon/actions/search';
import { fetchSuggestions, dismissSuggestion } from 'mastodon/actions/suggestions';

import SearchResults from '../components/search_results';

const mapStateToProps = state => ({
  results: state.getIn(['search', 'results']),
  suggestions: state.getIn(['suggestions', 'items']),
  searchTerm: state.getIn(['search', 'searchTerm']),
});

const mapDispatchToProps = dispatch => ({
  fetchSuggestions: () => dispatch(fetchSuggestions()),
  expandSearch: type => dispatch(expandSearch(type)),
  dismissSuggestion: account => dispatch(dismissSuggestion(account.get('id'))),
});

export default connect(mapStateToProps, mapDispatchToProps)(SearchResults);
