import { debounce } from 'lodash';
import { showAlert } from '../actions/alerts';

const defaultFailSuffix = 'FAIL';
let lastOnLine = true;

addEventListener('online', () => lastOnLine = true);

export default function errorsMiddleware() {
  return ({ dispatch }) => {
    const alertOffline = debounce(() => dispatch(showAlert('Zzz…', 'Device is offline')), 1024, { leading: true });

    return next => action => {
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
            if (navigator.onLine) {
              dispatch(showAlert('Oops!', 'An unexpected error occurred.'));
            } else if (lastOnLine) {
              lastOnLine = false;
              alertOffline.cancel();
              alertOffline();
            } else if (!action.passive) {
              alertOffline();
            }
          }
        }
      }

      return next(action);
    };
  };
};
