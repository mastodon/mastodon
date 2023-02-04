import { defineMessages } from 'react-intl';

const messages = defineMessages({
  unexpectedTitle: { id: 'alert.unexpected.title', defaultMessage: 'Oops!' },
  unexpectedMessage: { id: 'alert.unexpected.message', defaultMessage: 'An unexpected error occurred.' },
  rateLimitedTitle: { id: 'alert.rate_limited.title', defaultMessage: 'Rate limited' },
  rateLimitedMessage: { id: 'alert.rate_limited.message', defaultMessage: 'Please retry after {retry_time, time, medium}.' },
});

export const ALERT_SHOW    = 'ALERT_SHOW';
export const ALERT_DISMISS = 'ALERT_DISMISS';
export const ALERT_CLEAR   = 'ALERT_CLEAR';
export const ALERT_NOOP    = 'ALERT_NOOP';

export function dismissAlert(alert) {
  return {
    type: ALERT_DISMISS,
    alert,
  };
}

export function clearAlert() {
  return {
    type: ALERT_CLEAR,
  };
}

export function showAlert(title = messages.unexpectedTitle, message = messages.unexpectedMessage, message_values = undefined) {
  return {
    type: ALERT_SHOW,
    title,
    message,
    message_values,
  };
}

export function showAlertForError(error, skipNotFound = false) {
  if (error.response) {
    const { data, status, statusText, headers } = error.response;

    if (skipNotFound && (status === 404 || status === 410)) {
      // Skip these errors as they are reflected in the UI
      return { type: ALERT_NOOP };
    }

    if (status === 429 && headers['x-ratelimit-reset']) {
      const reset_date = new Date(headers['x-ratelimit-reset']);
      return showAlert(messages.rateLimitedTitle, messages.rateLimitedMessage, { 'retry_time': reset_date });
    }

    let message = statusText;
    let title   = `${status}`;

    if (data.error) {
      message = data.error;
    }

    return showAlert(title, message);
  } else {
    console.error(error);
    return showAlert();
  }
}
