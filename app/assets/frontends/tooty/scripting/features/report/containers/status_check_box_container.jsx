import { connect } from 'react-redux';
import StatusCheckBox from '../components/status_check_box';
import { toggleStatusReport } from '../../../actions/reports';
import Immutable from 'immutable';

const mapStateToProps = (state, { id }) => ({
  status: state.getIn(['statuses', id]),
  checked: state.getIn(['reports', 'new', 'status_ids'], Immutable.Set()).includes(id)
});

const mapDispatchToProps = (dispatch, { id }) => ({

  onToggle (e) {
    dispatch(toggleStatusReport(id, e.target.checked));
  }

});

export default connect(mapStateToProps, mapDispatchToProps)(StatusCheckBox);
