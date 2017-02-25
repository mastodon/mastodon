import { connect } from 'react-redux';
import {
  changeSearch,
  clearSearchSuggestions,
  fetchSearchSuggestions,
  resetSearch
} from '../../../actions/search';
import Search from '../components/search';

const mapStateToProps = state => ({
  suggestions: state.getIn(['search', 'suggestions']),
  value: state.getIn(['search', 'value'])
});

const mapDispatchToProps = dispatch => ({

  onChange (value) {
    dispatch(changeSearch(value));
  },

  onClear () {
    dispatch(clearSearchSuggestions());
  },

  onFetch (value) {
    dispatch(fetchSearchSuggestions(value));
  },

  onReset () {
    dispatch(resetSearch());
  }

});

export default connect(mapStateToProps, mapDispatchToProps)(Search);
