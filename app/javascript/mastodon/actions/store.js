import Immutable from 'immutable';

export const STORE_HYDRATE = 'STORE_HYDRATE';
export const STORE_HYDRATE_LAZY = 'STORE_HYDRATE_LAZY';

const convertState = rawState =>
  Immutable.fromJS(rawState, (k, v) =>
    Immutable.Iterable.isIndexed(v) ? v.toList() : v.toMap().mapKeys(x =>
      Number.isNaN(x * 1) ? x : x * 1));

export function hydrateStore(rawState) {
  const state = convertState(rawState);

  return {
    type: STORE_HYDRATE,
    state,
  };
};
