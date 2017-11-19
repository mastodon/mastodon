import { connect } from 'react-redux';
import { NotificationStack } from 'react-notification';
import { dismissAlert } from 'themes/glitch/actions/alerts';
import { getAlerts } from 'themes/glitch/selectors';

const mapStateToProps = state => ({
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
