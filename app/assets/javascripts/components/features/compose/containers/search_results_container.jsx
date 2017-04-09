import { connect } from 'react-redux';
import SearchResults from '../components/search_results';

const mapStateToProps = state => ({
  results: state.getIn(['search', 'results'])
});

export default connect(mapStateToProps)(SearchResults);
