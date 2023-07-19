import { injectIntl } from 'react-intl';

import { connect } from 'react-redux';

import { NotificationStack } from 'react-notification';

import { dismissAlert } from '../../../actions/alerts';
import { getAlerts } from '../../../selectors';

const formatIfNeeded = (intl, message, values) => {
  if (typeof message === 'object') {
    return intl.formatMessage(message, values);
  }

  return message;
};

const mapStateToProps = (state, { intl }) => ({
  notifications: getAlerts(state).map(alert => ({
    ...alert,
    action: formatIfNeeded(intl, alert.action, alert.values),
    title: formatIfNeeded(intl, alert.title, alert.values),
    message: formatIfNeeded(intl, alert.message, alert.values),
  })),
});

const mapDispatchToProps = (dispatch) => ({
  onDismiss (alert) {
    dispatch(dismissAlert(alert));
  },
});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(NotificationStack));
