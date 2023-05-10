import { Middleware } from 'redux';
import { showAlertForError } from '../../actions/alerts';
import { RootState } from '..';

const defaultFailSuffix = 'FAIL';

export const errorsMiddleware: Middleware<Record<string, never>, RootState> =
  ({ dispatch }) =>
  (next) =>
  (action) => {
    if (action.type && !action.skipAlert) {
      const isFail = new RegExp(`${defaultFailSuffix}$`, 'g');

      if (action.type.match(isFail)) {
        dispatch(showAlertForError(action.error, action.skipNotFound));
      }
    }

    return next(action);
  };
