import type { AnyAction, Middleware } from 'redux';

import { showAlertForError } from 'flavours/glitch/actions/alerts';

import type { RootState } from '..';

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
