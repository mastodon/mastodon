import { connect } from 'react-redux';
import {
  changeSearch,
  clearSearch,
  submitSearch,
  showSearch,
} from '../../../actions/search';
import Search from '../components/search';

const mapStateToProps = state => ({
  value: state.search.get('value'),
  submitted: state.search.get('submitted'),
});

const mapDispatchToProps = dispatch => ({

  onChange (value) {
    dispatch(changeSearch(value));
  },

  onClear () {
    dispatch(clearSearch());
  },

  onSubmit () {
    dispatch(submitSearch());
  },

  onShow () {
    dispatch(showSearch());
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(Search);
