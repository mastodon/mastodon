import { createAsyncThunk } from '@reduxjs/toolkit';
// eslint-disable-next-line @typescript-eslint/no-restricted-imports
import { useDispatch, useSelector } from 'react-redux';

import type { BaseThunkAPI } from '@reduxjs/toolkit/dist/createAsyncThunk';

import type { AppDispatch, RootState } from './store';

export const useAppDispatch = useDispatch.withTypes<AppDispatch>();
export const useAppSelector = useSelector.withTypes<RootState>();

export interface AsyncThunkRejectValue {
  skipAlert?: boolean;
  skipNotFound?: boolean;
  error?: unknown;
}

interface AppMeta {
  skipLoading?: boolean;
}

export const createAppAsyncThunk = createAsyncThunk.withTypes<{
  state: RootState;
  dispatch: AppDispatch;
  rejectValue: AsyncThunkRejectValue;
}>();

type AppThunkApi = Pick<
  BaseThunkAPI<
    RootState,
    unknown,
    AppDispatch,
    AsyncThunkRejectValue,
    AppMeta,
    AppMeta
  >,
  'getState' | 'dispatch'
>;

interface AppThunkOptions {
  skipLoading?: boolean;
}

const createBaseAsyncThunk = createAsyncThunk.withTypes<{
  state: RootState;
  dispatch: AppDispatch;
  rejectValue: AsyncThunkRejectValue;
  fulfilledMeta: AppMeta;
  rejectedMeta: AppMeta;
}>();

export function createThunk<Arg = void, Returned = void>(
  name: string,
  creator: (arg: Arg, api: AppThunkApi) => Returned | Promise<Returned>,
  options: AppThunkOptions = {},
) {
  return createBaseAsyncThunk(
    name,
    async (
      arg: Arg,
      { getState, dispatch, fulfillWithValue, rejectWithValue },
    ) => {
      try {
        const result = await creator(arg, { dispatch, getState });

        return fulfillWithValue(result, {
          skipLoading: options.skipLoading,
        });
      } catch (error) {
        return rejectWithValue({ error }, { skipLoading: true });
      }
    },
    {
      getPendingMeta() {
        if (options.skipLoading) return { skipLoading: true };
        return {};
      },
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
  thunkOptions?: AppThunkOptions,
): ReturnType<typeof createThunk<Args, LoadDataResult>>;

// Overload when the `onData` method returns discardLoadDataInPayload, then the payload is empty
export function createDataLoadingThunk<LoadDataResult, Args extends ArgsType>(
  name: string,
  loadData: LoadData<Args, LoadDataResult>,
  onDataOrThunkOptions?:
    | AppThunkOptions
    | OnData<Args, LoadDataResult, DiscardLoadData>,
  thunkOptions?: AppThunkOptions,
): ReturnType<typeof createThunk<Args, void>>;

// Overload when the `onData` method returns nothing, then the mayload is the `onData` result
export function createDataLoadingThunk<LoadDataResult, Args extends ArgsType>(
  name: string,
  loadData: LoadData<Args, LoadDataResult>,
  onDataOrThunkOptions?: AppThunkOptions | OnData<Args, LoadDataResult, void>,
  thunkOptions?: AppThunkOptions,
): ReturnType<typeof createThunk<Args, LoadDataResult>>;

// Overload when there is an `onData` method returning something
export function createDataLoadingThunk<
  LoadDataResult,
  Args extends ArgsType,
  Returned,
>(
  name: string,
  loadData: LoadData<Args, LoadDataResult>,
  onDataOrThunkOptions?:
    | AppThunkOptions
    | OnData<Args, LoadDataResult, Returned>,
  thunkOptions?: AppThunkOptions,
): ReturnType<typeof createThunk<Args, Returned>>;

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
 *   - `skipLoading` to avoid showing the loading bar when the request is in progress
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
    | AppThunkOptions
    | OnData<Args, LoadDataResult, Returned>,
  maybeThunkOptions?: AppThunkOptions,
) {
  let onData: OnData<Args, LoadDataResult, Returned> | undefined;
  let thunkOptions: AppThunkOptions | undefined;

  if (typeof onDataOrThunkOptions === 'function') onData = onDataOrThunkOptions;
  else if (typeof onDataOrThunkOptions === 'object')
    thunkOptions = onDataOrThunkOptions;

  if (maybeThunkOptions) {
    thunkOptions = maybeThunkOptions;
  }

  return createThunk<Args, Returned>(
    name,
    async (arg, { getState, dispatch }) => {
      const data = await loadData(arg, {
        dispatch,
        getState,
      });

      if (!onData) return data as Returned;

      const result = await onData(data, {
        dispatch,
        getState,
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
    thunkOptions,
  );
}
