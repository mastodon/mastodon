import { connect } from 'react-redux';
import { makeGetNotification } from '../../../selectors';
import Notification from '../components/notification';

const makeMapStateToProps = () => {
  const getNotification = makeGetNotification();

  const mapStateToProps = (state, props) => ({
    notification: getNotification(state, props.notification, props.accountId)
  });

  return mapStateToProps;
};

export default connect(makeMapStateToProps)(Notification);
