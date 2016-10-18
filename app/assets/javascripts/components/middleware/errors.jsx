import { showNotification } from '../actions/notifications';

const defaultFailSuffix = 'FAIL';

export default function errorsMiddleware() {
  return ({ dispatch }) => next => action => {
    if (action.type) {
      const isFail = new RegExp(`${defaultFailSuffix}$`, 'g');

      if (action.type.match(isFail)) {
        if (action.error.response) {
          const { data, status, statusText } = action.error.response;

          let message = statusText;
          let title   = `${status}`;

          if (data.error) {
            message = data.error;
          }

          dispatch(showNotification(title, message));
        } else {
          console.error(action.error);
          dispatch(showNotification('Oops!', 'An unexpected error occurred. Inspect the console for more details'));
        }
      }
    }

    return next(action);
  };
};
