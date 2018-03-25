import { defineMessages } from 'react-intl';
import { showAlert } from '../actions/alerts';

const defaultFailSuffix = 'FAIL';

const messages = defineMessages({
  unexpectedTitle: { id: 'alert.unexpected.title', defaultMessage: 'Oops!' },
  unexpectedMessage: { id: 'alert.unexpected.message', defaultMessage: 'An unexpected error occurred.' },
});

export default function errorsMiddleware() {
  return ({ dispatch }) => next => action => {
    if (action.type && !action.skipAlert) {
      const isFail = new RegExp(`${defaultFailSuffix}$`, 'g');

      if (action.type.match(isFail)) {
        if (action.error.response) {
          const { data, status, statusText } = action.error.response;

          let message = statusText;
          let title   = `${status}`;

          if (data.error) {
            message = data.error;
          }

          dispatch(showAlert(title, message));
        } else {
          console.error(action.error);
          dispatch(showAlert(messages.unexpectedTitle, messages.unexpectedMessage));
        }
      }
    }

    return next(action);
  };
};
