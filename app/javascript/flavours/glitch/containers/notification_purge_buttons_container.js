//  Package imports.
import { defineMessages, injectIntl } from 'react-intl';

import { connect } from 'react-redux';

//  Our imports.
import { openModal } from 'flavours/glitch/actions/modal';
import {
  deleteMarkedNotifications,
  enterNotificationClearingMode,
  markAllNotifications,
} from 'flavours/glitch/actions/notifications';
import NotificationPurgeButtons from 'flavours/glitch/components/notification_purge_buttons';

const messages = defineMessages({
  clearMessage: { id: 'notifications.marked_clear_confirmation', defaultMessage: 'Are you sure you want to permanently clear all selected notifications?' },
  clearConfirm: { id: 'notifications.marked_clear', defaultMessage: 'Clear selected notifications' },
});

const mapDispatchToProps = (dispatch, { intl }) => ({
  onEnterCleaningMode(yes) {
    dispatch(enterNotificationClearingMode(yes));
  },

  onDeleteMarked() {
    dispatch(openModal({
      modalType: 'CONFIRM',
      modalProps: {
        message: intl.formatMessage(messages.clearMessage),
        confirm: intl.formatMessage(messages.clearConfirm),
        onConfirm: () => dispatch(deleteMarkedNotifications()),
      },
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
