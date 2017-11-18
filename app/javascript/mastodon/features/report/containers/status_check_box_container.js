import { connect } from 'react-redux';
import StatusCheckBox from '../components/status_check_box';
import { toggleStatusReport } from '../../../actions/reports';
import { Set as ImmutableSet } from 'immutable';

const mapStateToProps = (state, { id }) => ({
  status: state.getIn(['statuses', id]),
  checked: state.getIn(['reports', 'new', 'status_ids'], ImmutableSet()).includes(id),
});

const mapDispatchToProps = (dispatch, { id }) => ({

  onToggle (e) {
    dispatch(toggleStatusReport(id, e.target.checked));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(StatusCheckBox);
