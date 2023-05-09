import { configureStore } from '@reduxjs/toolkit';
import { rootReducer } from '../reducers';
import { loadingBarMiddleware } from './middlewares/loading_bar';
import { errorsMiddleware } from './middlewares/errors';
import { soundsMiddleware } from './middlewares/sounds';
import { TypedUseSelectorHook, useDispatch, useSelector } from 'react-redux';

export const store = configureStore({
  reducer: rootReducer,
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware()
      .concat(
        loadingBarMiddleware({
          promiseTypeSuffixes: ['REQUEST', 'SUCCESS', 'FAIL'],
        })
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
