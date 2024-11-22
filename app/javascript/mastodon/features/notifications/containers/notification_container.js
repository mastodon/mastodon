import { connect } from 'react-redux';

import { mentionCompose } from '../../../actions/compose';
import {
  toggleFavourite,
  toggleReblog,
} from '../../../actions/interactions';
import {
  toggleStatusSpoilers,
} from '../../../actions/statuses';
import { makeGetNotification, makeGetStatus, makeGetReport } from '../../../selectors';
import Notification from '../components/notification';

const makeMapStateToProps = () => {
  const getNotification = makeGetNotification();
  const getStatus = makeGetStatus();
  const getReport = makeGetReport();

  const mapStateToProps = (state, props) => {
    const notification = getNotification(state, props.notification, props.accountId);
    return {
      notification: notification,
      status: notification.get('status') ? getStatus(state, { id: notification.get('status'), contextType: 'notifications' }) : null,
      report: notification.get('report') ? getReport(state, notification.get('report'), notification.getIn(['report', 'target_account', 'id'])) : null,
    };
  };

  return mapStateToProps;
};

const mapDispatchToProps = dispatch => ({
  onMention: (account) => {
    dispatch(mentionCompose(account));
  },

  onReblog (status, e) {
    dispatch(toggleReblog(status.get('id'), e.shiftKey));
  },

  onFavourite (status) {
    dispatch(toggleFavourite(status.get('id')));
  },

  onToggleHidden (status) {
    dispatch(toggleStatusSpoilers(status.get('id')));
  },
});

export default connect(makeMapStateToProps, mapDispatchToProps)(Notification);
