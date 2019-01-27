import { connect } from 'react-redux';
import { makeGetNotification, makeGetStatus } from '../../../selectors';
import Notification from '../components/notification';
import { openModal } from '../../../actions/modal';
import { mentionCompose } from '../../../actions/compose';
import {
  reblog,
  favourite,
  unreblog,
  unfavourite,
} from '../../../actions/interactions';
import {
  hideStatus,
  revealStatus,
} from '../../../actions/statuses';
import { boostModal } from '../../../initial_state';

const makeMapStateToProps = () => {
  const getNotification = makeGetNotification();
  const getStatus = makeGetStatus();

  const mapStateToProps = (state, props) => {
    const notification = getNotification(state, props.notification, props.accountId);
    return {
      notification: notification,
      status: notification.get('status') ? getStatus(state, { id: notification.get('status') }) : null,
    };
  };

  return mapStateToProps;
};

const mapDispatchToProps = dispatch => ({
  onMention: (account, router) => {
    dispatch(mentionCompose(account, router));
  },

  onModalReblog (status) {
    dispatch(reblog(status));
  },

  onReblog (status, e) {
    if (status.get('reblogged')) {
      dispatch(unreblog(status));
    } else {
      if (e.shiftKey || !boostModal) {
        this.onModalReblog(status);
      } else {
        dispatch(openModal('BOOST', { status, onReblog: this.onModalReblog }));
      }
    }
  },

  onFavourite (status) {
    if (status.get('favourited')) {
      dispatch(unfavourite(status));
    } else {
      dispatch(favourite(status));
    }
  },

  onToggleHidden (status) {
    if (status.get('hidden')) {
      dispatch(revealStatus(status.get('id')));
    } else {
      dispatch(hideStatus(status.get('id')));
    }
  },
});

export default connect(makeMapStateToProps, mapDispatchToProps)(Notification);
