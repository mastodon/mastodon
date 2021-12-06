import { connect } from 'react-redux';
import {
  changeSearch,
  clearSearch,
  submitSearch,
  showSearch,
} from '../../../actions/search_users';
import SearchUsers from '../components/search_users';

const mapStateToProps = state => ({
  value: state.getIn(['searchUsers', 'value']),
  submitted: state.getIn(['searchUsers', 'submitted']),
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

export default connect(mapStateToProps, mapDispatchToProps)(SearchUsers);

