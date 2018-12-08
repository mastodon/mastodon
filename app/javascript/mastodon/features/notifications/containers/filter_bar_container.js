import { connect } from 'react-redux';
import FilterBar from '../components/filter_bar';
import { changeSetting } from '../../../actions/settings';

const makeMapStateToProps = state => ({
  selectedFilter: state.getIn(['settings', 'notifications', 'quickFilter', 'active']),
  advancedMode: state.getIn(['settings', 'notifications', 'quickFilter', 'advanced']),
});

const mapDispatchToProps = (dispatch) => ({
  selectFilter (newActiveFilter) {
    dispatch(changeSetting(['notifications', 'quickFilter', 'active'], newActiveFilter));
  },
});

export default connect(makeMapStateToProps, mapDispatchToProps)(FilterBar);
