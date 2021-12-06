import { connect } from 'react-redux';
import SearchUsersResults from '../components/search_users_results';
import { fetchSuggestions, dismissSuggestion } from 'mastodon/actions/suggestions';
import { expandSearch } from 'mastodon/actions/search_users';

const mapStateToProps = state => ({
  results: state.getIn(['searchUsers', 'results']),
  suggestions: state.getIn(['suggestions', 'items']),
  searchTerm: state.getIn(['searchUsers', 'searchTerm']),
});

const mapDispatchToProps = dispatch => ({
  fetchSuggestions: () => dispatch(fetchSuggestions()),
  expandSearch: type => dispatch(expandSearch(type)),
  dismissSuggestion: account => dispatch(dismissSuggestion(account.get('id'))),
});

export default connect(mapStateToProps, mapDispatchToProps)(SearchUsersResults);
