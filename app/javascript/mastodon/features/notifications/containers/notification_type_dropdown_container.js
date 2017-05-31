import { connect } from 'react-redux';
import NotificationTypeDropdown from '../components/notification_type_dropdown';
import { changeComposeVisibility } from '../../../actions/compose';

const mapStateToProps = state => ({
  value: state.getIn(['compose', 'notification_type'])
});

const mapDispatchToProps = dispatch => ({

  onChange (value) {
    dispatch(handleChange(value));
  }

});

export default connect(mapStateToProps, mapDispatchToProps)(NotificationTypeDropdown);
