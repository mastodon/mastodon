import { Iterable, fromJS } from 'immutable';
import { hydrateCompose } from './compose';
import { importFetchedAccounts } from './importer';

export const STORE_HYDRATE = 'STORE_HYDRATE';
export const STORE_HYDRATE_LAZY = 'STORE_HYDRATE_LAZY';

const convertState = rawState =>
  fromJS(rawState, (k, v) =>
    Iterable.isIndexed(v) ? v.toList() : v.toMap());

export function hydrateStore(rawState) {
  return dispatch => {
    const state = convertState(rawState);

    dispatch({
      type: STORE_HYDRATE,
      state,
    });

    dispatch(hydrateCompose());
    dispatch(importFetchedAccounts(Object.values(rawState.accounts)));
  };
}
