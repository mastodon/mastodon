import { connect } from 'react-redux';
import SearchResults from '../components/search_results';
import { fetchTrends } from '../../../actions/trends';

const mapStateToProps = state => ({
  results: state.getIn(['search', 'results']),
  trends: state.get('trends'),
});

const mapDispatchToProps = dispatch => ({
  fetchTrends: () => dispatch(fetchTrends()),
});

export default connect(mapStateToProps, mapDispatchToProps)(SearchResults);
