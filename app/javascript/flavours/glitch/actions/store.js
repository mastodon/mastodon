import { Iterable, fromJS } from 'immutable';

import { hydrateCompose } from './compose';
import { importFetchedAccounts } from './importer';
import { hydrateSearch } from './search';
import { saveSettings } from './settings';

export const STORE_HYDRATE = 'STORE_HYDRATE';
export const STORE_HYDRATE_LAZY = 'STORE_HYDRATE_LAZY';

const convertState = rawState =>
  fromJS(rawState, (k, v) =>
    Iterable.isIndexed(v) ? v.toList() : v.toMap());

const applyMigrations = (state) => {
  return state.withMutations(state => {
    // Migrate glitch-soc local-only “Show unread marker” setting to Mastodon's setting
    if (state.getIn(['local_settings', 'notifications', 'show_unread']) !== undefined) {
      // Only change if the Mastodon setting does not deviate from default
      if (state.getIn(['settings', 'notifications', 'showUnread']) !== false) {
        state.setIn(['settings', 'notifications', 'showUnread'], state.getIn(['local_settings', 'notifications', 'show_unread']));
      }
      state.removeIn(['local_settings', 'notifications', 'show_unread']);
    }
  });
};

export function hydrateStore(rawState) {
  return dispatch => {
    const state = applyMigrations(convertState(rawState));

    dispatch({
      type: STORE_HYDRATE,
      state,
    });

    dispatch(hydrateCompose());
    dispatch(hydrateSearch());
    dispatch(importFetchedAccounts(Object.values(rawState.accounts)));
    dispatch(saveSettings());
  };
}
