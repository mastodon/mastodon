//  Package imports  //
import { connect } from 'react-redux';

//  Mastodon imports  //
import { makeGetNotification } from '../../../mastodon/selectors';

//  Our imports  //
import Notification from '.';
import { deleteNotification } from '../../../mastodon/actions/notifications';

const makeMapStateToProps = () => {
  const getNotification = makeGetNotification();

  const mapStateToProps = (state, props) => ({
    notification: getNotification(state, props.notification, props.accountId),
    settings: state.get('local_settings'),
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch) => ({
  onDeleteNotification (id) {
    dispatch(deleteNotification(id));
  },
});

export default connect(makeMapStateToProps, mapDispatchToProps)(Notification);
