/*

`<NotificationPurgeButtonsContainer>`
=========================

This container connects `<NotificationPurgeButtons>`s to the Redux store.

*/

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

Imports:
--------

*/

//  Package imports  //
import { connect } from 'react-redux';

//  Our imports  //
import NotificationPurgeButtons from './notification_purge_buttons';
import {
  deleteMarkedNotifications,
  enterNotificationClearingMode,
  markAllNotifications,
} from '../../../../mastodon/actions/notifications';
import { defineMessages, injectIntl } from 'react-intl';
import { openModal } from '../../../../mastodon/actions/modal';

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

Dispatch mapping:
-----------------

The `mapDispatchToProps()` function maps dispatches to our store to the
various props of our component. We only need to provide a dispatch for
deleting notifications.

*/

const messages = defineMessages({
  clearMessage: { id: 'notifications.marked_clear_confirmation', defaultMessage: 'Are you sure you want to permanently clear all selected notifications?' },
  clearConfirm: { id: 'notifications.marked_clear', defaultMessage: 'Clear selected notifications' },
});

const mapDispatchToProps = (dispatch, { intl }) => ({
  onEnterCleaningMode(yes) {
    dispatch(enterNotificationClearingMode(yes));
  },

  onDeleteMarked() {
    dispatch(openModal('CONFIRM', {
      message: intl.formatMessage(messages.clearMessage),
      confirm: intl.formatMessage(messages.clearConfirm),
      onConfirm: () => dispatch(deleteMarkedNotifications()),
    }));
  },

  onMarkAll() {
    dispatch(markAllNotifications(true));
  },

  onMarkNone() {
    dispatch(markAllNotifications(false));
  },

  onInvert() {
    dispatch(markAllNotifications(null));
  },
});

const mapStateToProps = state => ({
  markNewForDelete: state.getIn(['notifications', 'markNewForDelete']),
});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(NotificationPurgeButtons));
