import { connect } from 'react-redux';
import { makeGetNotification } from '../../../selectors';
import Notification from '../components/notification';
import { mentionCompose } from '../../../actions/compose';

const makeMapStateToProps = () => {
  const getNotification = makeGetNotification();

  const mapStateToProps = (state, props) => ({
    notification: getNotification(state, props.notification, props.accountId),
  });

  return mapStateToProps;
};

const mapDispatchToProps = dispatch => ({
  onMention: (account, router) => {
    dispatch(mentionCompose(account, router));
  },
});

export default connect(makeMapStateToProps, mapDispatchToProps)(Notification);
