import { connect }             from 'react-redux';
import { NotificationStack }   from 'react-notification';
import {
  dismissNotification,
  clearNotifications
}                              from '../../../actions/notifications';
import { getNotifications }    from '../../../selectors';

const mapStateToProps = (state, props) => ({
  notifications: getNotifications(state)
});

const mapDispatchToProps = (dispatch) => {
  return {
    onDismiss: notifiction => {
      dispatch(dismissNotification(notifiction));
    }
  };
};

export default connect(mapStateToProps, mapDispatchToProps)(NotificationStack);
