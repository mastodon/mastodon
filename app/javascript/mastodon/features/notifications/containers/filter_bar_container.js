import { connect } from 'react-redux';

import { setFilter } from '../../../actions/notifications';
import FilterBar from '../components/filter_bar';

const makeMapStateToProps = state => ({
  selectedFilter: state.getIn(['settings', 'notifications', 'quickFilter', 'active']),
  advancedMode: false,
});

const mapDispatchToProps = (dispatch) => ({
  selectFilter (newActiveFilter) {
    dispatch(setFilter(newActiveFilter));
  },
});

export default connect(makeMapStateToProps, mapDispatchToProps)(FilterBar);
