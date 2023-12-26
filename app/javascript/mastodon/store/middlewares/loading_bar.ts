import {
  isAsyncThunkAction,
  isPending as isThunkActionPending,
  isFulfilled as isThunkActionFulfilled,
  isRejected as isThunkActionRejected,
} from '@reduxjs/toolkit';
import { showLoading, hideLoading } from 'react-redux-loading-bar';
import type { AnyAction, Middleware } from 'redux';

import type { RootState } from '..';

interface Config {
  promiseTypeSuffixes?: string[];
}

const defaultTypeSuffixes: Config['promiseTypeSuffixes'] = [
  'PENDING',
  'FULFILLED',
  'REJECTED',
];

export const loadingBarMiddleware = (
  config: Config = {},
): Middleware<unknown, RootState> => {
  const promiseTypeSuffixes = config.promiseTypeSuffixes ?? defaultTypeSuffixes;

  return ({ dispatch }) =>
    (next) =>
    (action: AnyAction) => {
      let isPending = false;
      let isFulfilled = false;
      let isRejected = false;

      if (
        isAsyncThunkAction(action)
        // TODO: once we get the first use-case for it, add a check for skipLoading
      ) {
        if (isThunkActionPending(action)) isPending = true;
        else if (isThunkActionFulfilled(action)) isFulfilled = true;
        else if (isThunkActionRejected(action)) isRejected = true;
      } else if (
        action.type &&
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
