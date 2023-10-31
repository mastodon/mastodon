import { Iterable, Map, fromJS } from 'immutable';

import { createAccountFromServerJSON } from 'mastodon/models/account';

import { hydrateCompose } from './compose';
import { importFetchedAccounts } from './importer';
import { hydrateSearch } from './search';

export const STORE_HYDRATE = 'STORE_HYDRATE';
export const STORE_HYDRATE_LAZY = 'STORE_HYDRATE_LAZY';

const convertState = rawState => {
  return Map(Object.entries(rawState).map(([k, v]) => {
    switch (k) {
    case "accounts":
      return [k, Map(Object.entries(v).map(([accountId, account]) => [accountId, createAccountFromServerJSON(account)]))];
    default:
      return [k, fromJS(v, (_ik, iv) => Iterable.isIndexed(iv) ? iv.toList() : iv.toMap())];
    }
  }));
};

export function hydrateStore(rawState) {
  return dispatch => {
    const state = convertState(rawState);

    dispatch({
      type: STORE_HYDRATE,
      state,
    });

    dispatch(hydrateCompose());
    dispatch(hydrateSearch());
    dispatch(importFetchedAccounts(Object.values(rawState.accounts)));
  };
}
