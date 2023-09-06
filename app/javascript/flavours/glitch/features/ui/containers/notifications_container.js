import { injectIntl } from 'react-intl';

import { connect } from 'react-redux';

import { NotificationStack } from 'react-notification';

import { dismissAlert } from 'flavours/glitch/actions/alerts';
import { getAlerts } from 'flavours/glitch/selectors';

const mapStateToProps = (state, { intl }) => {
  const notifications = getAlerts(state);

  notifications.forEach(notification => ['title', 'message'].forEach(key => {
    const value = notification[key];

    if (typeof value === 'object') {
      notification[key] = intl.formatMessage(value, notification[`${key}_values`]);
    }
  }));

  return { notifications };
};

const mapDispatchToProps = (dispatch) => {
  return {
    onDismiss: alert => {
      dispatch(dismissAlert(alert));
    },
  };
};

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(NotificationStack));
