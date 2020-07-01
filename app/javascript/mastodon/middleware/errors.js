import { showAlertForError } from '../actions/alerts';

const defaultFailSuffix = 'FAIL';

export default function errorsMiddleware() {
  return ({ dispatch }) => next => action => {
    if (action.type && !action.skipAlert) {
      const isFail = new RegExp(`${defaultFailSuffix}$`, 'g');

      if (action.type.match(isFail)) {
        dispatch(showAlertForError(action.error, action.skipNotFound));
      }
    }

    return next(action);
  };
};
