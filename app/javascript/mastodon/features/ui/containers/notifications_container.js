import { connect } from 'react-redux';
import { NotificationStack } from 'react-notification';
import {
  dismissAlert,
  clearAlerts,
} from '../../../actions/alerts';
import { getAlerts } from '../../../selectors';

const mapStateToProps = (state, props) => ({
  notifications: getAlerts(state),
});

const mapDispatchToProps = (dispatch) => {
  return {
    onDismiss: alert => {
      dispatch(dismissAlert(alert));
    },
  };
};

export default connect(mapStateToProps, mapDispatchToProps)(NotificationStack);
