import { connect } from 'react-redux';

import {
  changeSearch,
  clearSearch,
  submitSearch,
  showSearch,
} from 'flavours/glitch/actions/search';

import Search from '../components/search';

const mapStateToProps = state => ({
  value: state.getIn(['search', 'value']),
  submitted: state.getIn(['search', 'submitted']),
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
