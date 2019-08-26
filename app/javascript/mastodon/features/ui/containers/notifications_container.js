import { injectIntl } from 'react-intl';
import { connect } from 'react-redux';
import { NotificationStack } from 'react-notification';
import { dismissAlert } from '../../../actions/alerts';
import { getAlerts } from '../../../selectors';

const mapStateToProps = (state, { intl }) => {
  const notifications = getAlerts(state);

  notifications.forEach(notification => ['title', 'message'].forEach(key => {
    const value = notification[key];

    if (typeof value === 'object') {
      if (Array.isArray(value)) {
        notification[key] = intl.formatMessage(value[0], value[1]);
      } else {
        notification[key] = intl.formatMessage(value);
      }
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
