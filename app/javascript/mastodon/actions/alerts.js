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

export const dismissAlert = alert => ({
  type: ALERT_DISMISS,
  alert,
});

export const clearAlert = () => ({
  type: ALERT_CLEAR,
});

export const showAlert = alert => ({
  type: ALERT_SHOW,
  alert,
});

export const showAlertForError = (error, skipNotFound = false) => {
  if (error.response) {
    const { data, status, statusText, headers } = error.response;

    // Skip these errors as they are reflected in the UI
    if (skipNotFound && (status === 404 || status === 410)) {
      return { type: ALERT_NOOP };
    }

    // Rate limit errors
    if (status === 429 && headers['x-ratelimit-reset']) {
      return showAlert({
        title: messages.rateLimitedTitle,
        message: messages.rateLimitedMessage,
        values: { 'retry_time': new Date(headers['x-ratelimit-reset']) },
      });
    }

    return showAlert({
      title: `${status}`,
      message: data.error || statusText,
    });
  }

  console.error(error);

  return showAlert({
    title: messages.unexpectedTitle,
    message: messages.unexpectedMessage,
  });
}
