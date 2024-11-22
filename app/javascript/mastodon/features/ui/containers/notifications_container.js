import { injectIntl } from 'react-intl';

import { connect } from 'react-redux';

import { NotificationStack } from 'react-notification';

import { dismissAlert } from 'mastodon/actions/alerts';
import { getAlerts } from 'mastodon/selectors';

const mapStateToProps = (state, { intl }) => ({
  notifications: getAlerts(state, { intl }),
});

const mapDispatchToProps = (dispatch) => ({
  onDismiss (alert) {
    dispatch(dismissAlert(alert));
  },
});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(NotificationStack));
