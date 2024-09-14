import {
  isAsyncThunkAction,
  isPending as isThunkActionPending,
  isFulfilled as isThunkActionFulfilled,
  isRejected as isThunkActionRejected,
  isAction,
} from '@reduxjs/toolkit';
import type { Middleware, UnknownAction } from '@reduxjs/toolkit';

import { showLoading, hideLoading } from 'react-redux-loading-bar';

import type { RootState } from '..';

interface Config {
  promiseTypeSuffixes?: string[];
}

const defaultTypeSuffixes: Config['promiseTypeSuffixes'] = [
  'PENDING',
  'FULFILLED',
  'REJECTED',
];

interface ActionWithSkipLoading extends UnknownAction {
  skipLoading: boolean;
}

function isActionWithSkipLoading(
  action: unknown,
): action is ActionWithSkipLoading {
  return (
    isAction(action) &&
    'skipLoading' in action &&
    typeof action.skipLoading === 'boolean'
  );
}

export const loadingBarMiddleware = (
  config: Config = {},
): Middleware<{ skipLoading?: boolean }, RootState> => {
  const promiseTypeSuffixes = config.promiseTypeSuffixes ?? defaultTypeSuffixes;

  return ({ dispatch }) =>
    (next) =>
    (action) => {
      let isPending = false;
      let isFulfilled = false;
      let isRejected = false;

      if (
        isAsyncThunkAction(action) &&
        'useLoadingBar' in action.meta &&
        action.meta.useLoadingBar
      ) {
        if (isThunkActionPending(action)) isPending = true;
        else if (isThunkActionFulfilled(action)) isFulfilled = true;
        else if (isThunkActionRejected(action)) isRejected = true;
      } else if (
        isActionWithSkipLoading(action) &&
        !action.skipLoading &&
        typeof action.type === 'string'
      ) {
        const [PENDING, FULFILLED, REJECTED] = promiseTypeSuffixes;

        const isPendingRegexp = new RegExp(`${PENDING}$`, 'g');
        const isFulfilledRegexp = new RegExp(`${FULFILLED}$`, 'g');
        const isRejectedRegexp = new RegExp(`${REJECTED}$`, 'g');

        if (action.type.match(isPendingRegexp)) {
          isPending = true;
        } else if (action.type.match(isFulfilledRegexp)) {
          isFulfilled = true;
        } else if (action.type.match(isRejectedRegexp)) {
          isRejected = true;
        }
      }

      if (isPending) {
        dispatch(showLoading());
      } else if (isFulfilled || isRejected) {
        dispatch(hideLoading());
      }

      return next(action);
    };
};
