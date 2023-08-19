import { createSelector } from 'reselect';

import type { Account } from 'mastodon/initial_state';

import type { RootState } from '../store';

const getAccountBase = (state: RootState, id: string): Account | null => {
  return state.getIn(['accounts', id], null);
};

const getAccountCounters = (state: RootState, id: string) => {
  return state.getIn(['accounts_counters', id], null);
};

const getAccountRelationship = (state: RootState, id: string) => {
  return state.getIn(['relationships', id], null);
};

const getAccountMoved = (state: RootState, id: string) => {
  return state.getIn(['accounts', state.getIn(['accounts', id, 'moved'])]);
};

export const makeGetAccount = () => {
  return createSelector(
    [
      getAccountBase,
      getAccountCounters,
      getAccountRelationship,
      getAccountMoved,
    ],
    (base, counters, relationship, moved) => {
      if (base === null) {
        return null;
      }

      return base.merge(counters).withMutations((map) => {
        map.set('relationship', relationship);
        map.set('moved', moved);
      });
    }
  );
};
