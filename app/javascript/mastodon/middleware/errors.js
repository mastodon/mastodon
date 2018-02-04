import { showAlert } from '../actions/alerts';

const defaultFailSuffix = 'FAIL';

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
          dispatch(showAlert('Oops!', 'An unexpected error occurred.'));
        }
      }
    }

    return next(action);
  };
};
