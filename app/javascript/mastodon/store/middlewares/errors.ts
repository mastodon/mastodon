import { isAction } from '@reduxjs/toolkit';
import type { Action, Middleware } from '@reduxjs/toolkit';

import type { RootState } from '..';
import { showAlertForError } from '../../actions/alerts';

const defaultFailSuffix = 'FAIL';
const isFailedAction = new RegExp(`${defaultFailSuffix}$`, 'g');

interface ActionWithMaybeAlertParams extends Action {
  skipAlert?: boolean;
  skipNotFound?: boolean;
  error?: unknown;
}

function isActionWithmaybeAlertParams(
  action: unknown,
): action is ActionWithMaybeAlertParams {
  return isAction(action);
}

export const errorsMiddleware: Middleware<Record<string, never>, RootState> =
  ({ dispatch }) =>
  (next) =>
  (action) => {
    if (
      isActionWithmaybeAlertParams(action) &&
      !action.skipAlert &&
      action.type.match(isFailedAction)
    ) {
      dispatch(showAlertForError(action.error, action.skipNotFound));
    }

    return next(action);
  };
