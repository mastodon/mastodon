import { defineMessages } from 'react-intl';

const messages = defineMessages({
  unexpectedTitle: { id: 'alert.unexpected.title', defaultMessage: 'Oops!' },
  unexpectedMessage: { id: 'alert.unexpected.message', defaultMessage: 'An unexpected error occurred.' },
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
};

export function clearAlert() {
  return {
    type: ALERT_CLEAR,
  };
};

export function showAlert(title = messages.unexpectedTitle, message = messages.unexpectedMessage) {
  return {
    type: ALERT_SHOW,
    title,
    message,
  };
};

export function showAlertForError(error) {
  if (error.response) {
    const { data, status, statusText } = error.response;

    if (status === 404 || status === 410) {
      // Skip these errors as they are reflected in the UI
      return { type: ALERT_NOOP };
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
