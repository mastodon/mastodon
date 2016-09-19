import { connect }             from 'react-redux';
import { NotificationStack }   from 'react-notification';
import { dismissNotification } from '../../../actions/notifications';

const mapStateToProps = (state, props) => {
  return {
    notifications: state.get('notifications').map((item, i) => ({
      message: item.get('message'),
      title: item.get('title'),
      key: i,
      action: 'Dismiss',
      dismissAfter: 5000
    })).toJS()
  };
};

const mapDispatchToProps = (dispatch) => {
  return {
    onDismiss: notifiction => {
      dispatch(dismissNotification(notifiction));
    }
  };
};

export default connect(mapStateToProps, mapDispatchToProps)(NotificationStack);
