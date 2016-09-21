import { connect }             from 'react-redux';
import { NotificationStack }   from 'react-notification';
import {
  dismissNotification,
  clearNotifications
}                              from '../../../actions/notifications';

const mapStateToProps = (state, props) => ({
  notifications: state.get('notifications').map((item, i) => ({
    message: item.get('message'),
    title: item.get('title'),
    key: item.get('key'),
    dismissAfter: 5000
  })).toJS()
});

const mapDispatchToProps = (dispatch) => {
  return {
    onDismiss: notifiction => {
      dispatch(dismissNotification(notifiction));
    }
  };
};

export default connect(mapStateToProps, mapDispatchToProps)(NotificationStack);
