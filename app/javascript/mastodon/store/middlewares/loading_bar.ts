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
      if (action.type && !action.skipLoading) {
        const [PENDING, FULFILLED, REJECTED] = promiseTypeSuffixes;

        const isPending = new RegExp(`${PENDING}$`, 'g');
        const isFulfilled = new RegExp(`${FULFILLED}$`, 'g');
        const isRejected = new RegExp(`${REJECTED}$`, 'g');

        if (typeof action.type === 'string') {
          if (action.type.match(isPending)) {
            dispatch(showLoading());
          } else if (
            action.type.match(isFulfilled) ??
            action.type.match(isRejected)
          ) {
            dispatch(hideLoading());
          }
        }
      }

      return next(action);
    };
};
