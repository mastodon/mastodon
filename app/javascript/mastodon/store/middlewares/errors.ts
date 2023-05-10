import type { AnyAction, Middleware } from 'redux';

import type { RootState } from '..';
import { showAlertForError } from '../../actions/alerts';

const defaultFailSuffix = 'FAIL';

export const errorsMiddleware: Middleware<Record<string, never>, RootState> =
  ({ dispatch }) =>
  (next) =>
  (action: AnyAction & { skipAlert?: boolean; skipNotFound?: boolean }) => {
    if (action.type && !action.skipAlert) {
      const isFail = new RegExp(`${defaultFailSuffix}$`, 'g');

      if (typeof action.type === 'string' && action.type.match(isFail)) {
        dispatch(showAlertForError(action.error, action.skipNotFound));
      }
    }

    return next(action);
  };
