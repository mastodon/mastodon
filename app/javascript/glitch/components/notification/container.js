//  Package imports  //
import { connect } from 'react-redux';

//  Mastodon imports  //
import { makeGetNotification } from '../../../mastodon/selectors';

//  Our imports  //
import Notification from '.';

const makeMapStateToProps = () => {
  const getNotification = makeGetNotification();

  const mapStateToProps = (state, props) => ({
    notification: getNotification(state, props.notification, props.accountId),
    settings: state.get('local_settings'),
  });

  return mapStateToProps;
};

export default connect(makeMapStateToProps)(Notification);
