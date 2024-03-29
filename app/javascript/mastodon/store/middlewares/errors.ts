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

// eslint-disable-next-line @typescript-eslint/ban-types -- we need to use `{}` here to ensure the dispatch types can be merged
export const errorsMiddleware: Middleware<{}, RootState> =
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
