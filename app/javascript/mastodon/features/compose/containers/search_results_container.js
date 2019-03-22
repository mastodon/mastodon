import { connect } from 'react-redux';
import SearchResults from '../components/search_results';
import { fetchSuggestions, dismissSuggestion } from '../../../actions/suggestions';

const mapStateToProps = state => ({
  results: state.getIn(['search', 'results']),
  suggestions: state.getIn(['suggestions', 'items']),
});

const mapDispatchToProps = dispatch => ({
  fetchSuggestions: () => dispatch(fetchSuggestions()),
  dismissSuggestion: account => dispatch(dismissSuggestion(account.get('id'))),
});

export default connect(mapStateToProps, mapDispatchToProps)(SearchResults);
