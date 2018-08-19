import { connect } from 'react-redux';
import SearchResults from '../components/search_results';

const mapStateToProps = state => ({
  results: state.getIn(['search', 'results']),
  query: state.getIn(['search', 'value']),
});

export default connect(mapStateToProps)(SearchResults);
