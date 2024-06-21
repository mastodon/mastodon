import {
  isAction,
  isAsyncThunkAction,
  isRejectedWithValue,
} from '@reduxjs/toolkit';
import type { Action, Middleware } from '@reduxjs/toolkit';

import type { RootState } from '..';
import { showAlertForError } from '../../actions/alerts';
import type { AsyncThunkRejectValue } from '../typed_functions';

const defaultFailSuffix = 'FAIL';
const isFailedAction = new RegExp(`${defaultFailSuffix}$`, 'g');

interface ActionWithMaybeAlertParams extends Action, AsyncThunkRejectValue {}

interface RejectedAction extends Action {
  payload: AsyncThunkRejectValue;
}

function isRejectedActionWithPayload(
  action: unknown,
): action is RejectedAction {
  return isAsyncThunkAction(action) && isRejectedWithValue(action);
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
    if (isRejectedActionWithPayload(action) && !action.payload.skipAlert) {
      dispatch(
        showAlertForError(action.payload.error, action.payload.skipNotFound),
      );
    } else if (
      isActionWithmaybeAlertParams(action) &&
      !action.skipAlert &&
      action.type.match(isFailedAction)
    ) {
      dispatch(showAlertForError(action.error, action.skipNotFound));
    }

    return next(action);
  };
