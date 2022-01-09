import { connect } from 'react-redux';
import SearchUsersResults from '../components/search_users_results';
import { expandSearch } from 'mastodon/actions/search_users';

const mapStateToProps = state => ({
  results: state.getIn(['searchUsers', 'results']),
  searchTerm: state.getIn(['searchUsers', 'searchTerm']),
});

const mapDispatchToProps = dispatch => ({
  expandSearch: type => dispatch(expandSearch(type)),
});

export default connect(mapStateToProps, mapDispatchToProps)(SearchUsersResults);
