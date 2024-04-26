import { connect } from 'react-redux';

import { expandSearch } from 'mastodon/actions/search';

import SearchResults from '../components/search_results';

const mapStateToProps = state => ({
  results: state.getIn(['search', 'results']),
  searchTerm: state.getIn(['search', 'searchTerm']),
});

const mapDispatchToProps = dispatch => ({
  expandSearch: type => dispatch(expandSearch(type)),
});

export default connect(mapStateToProps, mapDispatchToProps)(SearchResults);
