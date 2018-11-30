import { connect } from 'react-redux';
import FilterBar from '../components/filter_bar';
import { changeSetting } from '../../../actions/settings';

const makeMapStateToProps = state => ({
  selectedFilter: state.getIn(['settings', 'notifications', 'filter']),
});

const mapDispatchToProps = (dispatch) => ({
  selectFilter (newActiveFilter) {
    dispatch(changeSetting(['notifications', 'filter'], newActiveFilter));
  },
});

export default connect(makeMapStateToProps, mapDispatchToProps)(FilterBar);
