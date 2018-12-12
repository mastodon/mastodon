import { connect } from 'react-redux';
import FilterBar from '../components/filter_bar';
import { setFilter } from '../../../actions/notifications';

const makeMapStateToProps = state => ({
  selectedFilter: state.getIn(['settings', 'notifications', 'quickFilter', 'active']),
  advancedMode: state.getIn(['settings', 'notifications', 'quickFilter', 'advanced']),
});

const mapDispatchToProps = (dispatch) => ({
  selectFilter (newActiveFilter) {
    dispatch(setFilter(newActiveFilter));
  },
});

export default connect(makeMapStateToProps, mapDispatchToProps)(FilterBar);
