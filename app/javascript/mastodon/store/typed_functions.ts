import type {
  ActionCreatorWithPreparedPayload,
  GetThunkAPI,
} from '@reduxjs/toolkit';
import {
  createAsyncThunk as rtkCreateAsyncThunk,
  createSelector,
  createAction,
} from '@reduxjs/toolkit';
// eslint-disable-next-line @typescript-eslint/no-restricted-imports
import { useDispatch, useSelector } from 'react-redux';

import type { AppDispatch, RootState } from './store';

export const useAppDispatch = useDispatch.withTypes<AppDispatch>();
export const useAppSelector = useSelector.withTypes<RootState>();

export interface AsyncThunkRejectValue {
  skipAlert?: boolean;
  skipNotFound?: boolean;
  error?: unknown;
}

interface AppMeta {
  useLoadingBar?: boolean;
}

export const createAppAsyncThunk = rtkCreateAsyncThunk.withTypes<{
  state: RootState;
  dispatch: AppDispatch;
  rejectValue: AsyncThunkRejectValue;
}>();

export const createAppSelector = createSelector.withTypes<RootState>();

interface AppThunkConfig {
  state: RootState;
  dispatch: AppDispatch;
  rejectValue: AsyncThunkRejectValue;
  fulfilledMeta: AppMeta;
  rejectedMeta: AppMeta;
}
export type AppThunkApi = Pick<
  GetThunkAPI<AppThunkConfig>,
  'getState' | 'dispatch' | 'requestId'
>;

interface AppThunkOptions<Arg> {
  useLoadingBar?: boolean;
  condition?: (
    arg: Arg,
    { getState }: { getState: AppThunkApi['getState'] },
  ) => boolean;
}

// Type definitions for the sync thunks.
type AppThunk<Arg = void, Returned = void> = (
  arg: Arg,
) => (dispatch: AppDispatch, getState: () => RootState) => Returned;

type AppThunkCreator<Arg = void, Returned = void, ExtraArg = unknown> = (
  arg: Arg,
  api: Pick<AppThunkApi, 'getState' | 'dispatch'>,
  extra?: ExtraArg,
) => Returned;

type AppThunkActionCreator<
  Arg = void,
  Returned = void,
> = ActionCreatorWithPreparedPayload<
  [Returned, Arg],
  Returned,
  string,
  never,
  { arg: Arg }
>;

// Version that does not dispatch it's own action.
export function createAppThunk<Arg = void, Returned = void, ExtraArg = unknown>(
  creator: AppThunkCreator<Arg, Returned, ExtraArg>,
  extra?: ExtraArg,
): AppThunk<Arg, Returned>;

// Version that dispatches an named action with the result of the creator callback.
export function createAppThunk<Arg = void, Returned = void, ExtraArg = unknown>(
  name: string,
  creator: AppThunkCreator<Arg, Returned, ExtraArg>,
  extra?: ExtraArg,
): AppThunk<Arg, Returned> & AppThunkActionCreator<Arg, Returned>;

/** Creates a thunk that dispatches an action. */
export function createAppThunk<Arg = void, Returned = void, ExtraArg = unknown>(
  nameOrCreator: string | AppThunkCreator<Arg, Returned, ExtraArg>,
  maybeCreatorOrExtra?: AppThunkCreator<Arg, Returned, ExtraArg> | ExtraArg,
  maybeExtra?: ExtraArg,
) {
  const isDispatcher = typeof nameOrCreator === 'string';
  const name = isDispatcher ? nameOrCreator : undefined;
  const creator = isDispatcher
    ? (maybeCreatorOrExtra as AppThunkCreator<Arg, Returned, ExtraArg>)
    : nameOrCreator;
  const extra = isDispatcher ? maybeExtra : (maybeCreatorOrExtra as ExtraArg);
  let action: null | AppThunkActionCreator<Arg, Returned> = null;

  // Creates a thunk that dispatches the action with the result of the creator.
  const actionCreator: AppThunk<Arg, Returned> = (arg) => {
    return (dispatch, getState) => {
      const result = creator(arg, { dispatch, getState }, extra);
      if (action) {
        // Dispatches the action with the result.
        const actionObj = action(result, arg);
        dispatch(actionObj);
      }
      return result;
    };
  };

  // No action name provided, return the thunk directly.
  if (!name) {
    return actionCreator;
  }

  // Create the action and assign the action creator to it in order
  // to have things like `toString` and `match` available.
  action = createAction(name, (payload: Returned, arg: Arg) => ({
    payload,
    meta: {
      arg,
    },
  }));

  return Object.assign(actionCreator, action);
}

const createBaseAsyncThunk = rtkCreateAsyncThunk.withTypes<AppThunkConfig>();

export function createAsyncThunk<Arg = void, Returned = void>(
  name: string,
  creator: (arg: Arg, api: AppThunkApi) => Returned | Promise<Returned>,
  options: AppThunkOptions<Arg> = {},
) {
  return createBaseAsyncThunk(
    name,
    async (
      arg: Arg,
      { getState, dispatch, requestId, fulfillWithValue, rejectWithValue },
    ) => {
      try {
        const result = await creator(arg, { dispatch, getState, requestId });

        return fulfillWithValue(result, {
          useLoadingBar: options.useLoadingBar,
        });
      } catch (error) {
        return rejectWithValue(
          { error },
          {
            useLoadingBar: options.useLoadingBar,
          },
        );
      }
    },
    {
      getPendingMeta() {
        if (options.useLoadingBar) return { useLoadingBar: true };
        return {};
      },
      condition: options.condition,
    },
  );
}

const discardLoadDataInPayload = Symbol('discardLoadDataInPayload');
type DiscardLoadData = typeof discardLoadDataInPayload;

type OnData<ActionArg, LoadDataResult, ReturnedData> = (
  data: LoadDataResult,
  api: AppThunkApi & {
    actionArg: ActionArg;
    discardLoadData: DiscardLoadData;
  },
) => ReturnedData | DiscardLoadData | Promise<ReturnedData | DiscardLoadData>;

type LoadData<Args, LoadDataResult> = (
  args: Args,
  api: AppThunkApi,
) => Promise<LoadDataResult>;

type ArgsType = Record<string, unknown> | undefined;

// Overload when there is no `onData` method, the payload is the `onData` result
export function createDataLoadingThunk<LoadDataResult, Args extends ArgsType>(
  name: string,
  loadData: (args: Args) => Promise<LoadDataResult>,
  thunkOptions?: AppThunkOptions<Args>,
): ReturnType<typeof createAsyncThunk<Args, LoadDataResult>>;

// Overload when the `onData` method returns discardLoadDataInPayload, then the payload is empty
export function createDataLoadingThunk<LoadDataResult, Args extends ArgsType>(
  name: string,
  loadData: LoadData<Args, LoadDataResult>,
  onDataOrThunkOptions?:
    | AppThunkOptions<Args>
    | OnData<Args, LoadDataResult, DiscardLoadData>,
  thunkOptions?: AppThunkOptions<Args>,
): ReturnType<typeof createAsyncThunk<Args, void>>;

// Overload when the `onData` method returns nothing, then the payload is the `onData` result
export function createDataLoadingThunk<LoadDataResult, Args extends ArgsType>(
  name: string,
  loadData: LoadData<Args, LoadDataResult>,
  onDataOrThunkOptions?:
    | AppThunkOptions<Args>
    | OnData<Args, LoadDataResult, void>,
  thunkOptions?: AppThunkOptions<Args>,
): ReturnType<typeof createAsyncThunk<Args, LoadDataResult>>;

// Overload when there is an `onData` method returning something
export function createDataLoadingThunk<
  LoadDataResult,
  Args extends ArgsType,
  Returned,
>(
  name: string,
  loadData: LoadData<Args, LoadDataResult>,
  onDataOrThunkOptions?:
    | AppThunkOptions<Args>
    | OnData<Args, LoadDataResult, Returned>,
  thunkOptions?: AppThunkOptions<Args>,
): ReturnType<typeof createAsyncThunk<Args, Returned>>;

/**
 * This function creates a Redux Thunk that handles loading data asynchronously (usually from the API), dispatching `pending`, `fullfilled` and `rejected` actions.
 *
 * You can run a callback on the `onData` results to either dispatch side effects or modify the payload.
 *
 * It is a wrapper around RTK's [`createAsyncThunk`](https://redux-toolkit.js.org/api/createAsyncThunk)
 * @param name Prefix for the actions types
 * @param loadData Function that loads the data. It's (object) argument will become the thunk's argument
 * @param onDataOrThunkOptions
 *   Callback called on the results from `loadData`.
 *
 *   First argument will be the return from `loadData`.
 *
 *   Second argument is an object with: `dispatch`, `getState` and `discardLoadData`.
 *   It can return:
 *   - `undefined` (or no explicit return), meaning that the `onData` results will be the payload
 *   - `discardLoadData` to discard the `onData` results and return an empty payload
 *   - anything else, which will be the payload
 *
 *   You can also omit this parameter and pass `thunkOptions` directly
 * @param maybeThunkOptions
 *   Additional Mastodon specific options for the thunk. Currently supports:
 *   - `useLoadingBar` to display a loading bar while this action is pending. Defaults to true.
 *   - `condition` is passed to `createAsyncThunk` (https://redux-toolkit.js.org/api/createAsyncThunk#canceling-before-execution)
 * @returns The created thunk
 */
export function createDataLoadingThunk<
  LoadDataResult,
  Args extends ArgsType,
  Returned,
>(
  name: string,
  loadData: LoadData<Args, LoadDataResult>,
  onDataOrThunkOptions?:
    | AppThunkOptions<Args>
    | OnData<Args, LoadDataResult, Returned>,
  maybeThunkOptions?: AppThunkOptions<Args>,
) {
  let onData: OnData<Args, LoadDataResult, Returned> | undefined;
  let thunkOptions: AppThunkOptions<Args> | undefined;

  if (typeof onDataOrThunkOptions === 'function') onData = onDataOrThunkOptions;
  else if (typeof onDataOrThunkOptions === 'object')
    thunkOptions = onDataOrThunkOptions;

  if (maybeThunkOptions) {
    thunkOptions = maybeThunkOptions;
  }

  return createAsyncThunk<Args, Returned>(
    name,
    async (arg, { getState, dispatch, requestId }) => {
      const data = await loadData(arg, {
        dispatch,
        getState,
        requestId,
      });

      if (!onData) return data as Returned;

      const result = await onData(data, {
        dispatch,
        getState,
        requestId,
        discardLoadData: discardLoadDataInPayload,
        actionArg: arg,
      });

      // if there is no return in `onData`, we return the `onData` result
      if (typeof result === 'undefined') return data as Returned;
      // the user explicitely asked to discard the payload
      else if (result === discardLoadDataInPayload)
        return undefined as Returned;
      else return result;
    },
    {
      useLoadingBar: thunkOptions?.useLoadingBar ?? true,
      condition: thunkOptions?.condition,
    },
  );
}
