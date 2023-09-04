import type { TypedUseSelectorHook } from 'react-redux';
import { useDispatch, useSelector } from 'react-redux';

import { configureStore } from '@reduxjs/toolkit';

import { rootReducer } from '../reducers';

import { errorsMiddleware } from './middlewares/errors';
import { loadingBarMiddleware } from './middlewares/loading_bar';
import { soundsMiddleware } from './middlewares/sounds';

export const store = configureStore({
  reducer: rootReducer,
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
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
    })
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
// Inferred type: {posts: PostsState, comments: CommentsState, users: UsersState}
export type AppDispatch = typeof store.dispatch;

export const useAppDispatch: () => AppDispatch = useDispatch;
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;
