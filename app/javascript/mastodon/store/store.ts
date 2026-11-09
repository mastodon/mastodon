import { configureStore } from '@reduxjs/toolkit';

import {
  SHOW as LOADING_BAR_SHOW,
  HIDE as LOADING_BAR_HIDE,
} from 'react-redux-loading-bar';

import { HEIGHT_CACHE_SET } from '../actions/height_cache';
import { changeSetting } from '../actions/settings';
import { rootReducer } from '../reducers';
import { isDevelopment } from '../utils/environment';

import { errorsMiddleware } from './middlewares/errors';
import { loadingBarMiddleware } from './middlewares/loading_bar';
import { soundsMiddleware } from './middlewares/sounds';

export const defaultMiddleware = {
  // In development, Redux Toolkit enables 2 default middlewares to detect
  // common issues with states. Unfortunately, our use of ImmutableJS for state
  // triggers both, so lets disable them until our state is fully refactored

  // https://redux-toolkit.js.org/api/serializabilityMiddleware
  // This checks recursively that every values in the state are serializable in JSON
  // Which is not the case, as we use ImmutableJS structures, but also File objects
  serializableCheck: false,

  // https://redux-toolkit.js.org/api/immutabilityMiddleware
  // This checks recursively if every value in the state is immutable (ie, a JS primitive type)
  // But this is not the case, as our Root State is an ImmutableJS map, which is an object
  immutableCheck: false,
} as const;

export const store = configureStore({
  devTools: isDevelopment()
    ? {
        maxAge: 1000,
        actionCreators: {
          changeSetting,
        },
        actionsDenylist: [HEIGHT_CACHE_SET, LOADING_BAR_SHOW, LOADING_BAR_HIDE],
      }
    : undefined,
  reducer: rootReducer,
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware(defaultMiddleware)
      .concat(
        loadingBarMiddleware({
          promiseTypeSuffixes: ['REQUEST', 'SUCCESS', 'FAIL'],
        }),
      )
      .concat(errorsMiddleware)
      .concat(soundsMiddleware()),
});

// Infer the `RootState` and `AppDispatch` types from the store itself
export type RootState = ReturnType<typeof rootReducer>;
export type AppDispatch = typeof store.dispatch;
export type GetState = typeof store.getState;
