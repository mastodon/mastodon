import type { Map as ImmutableMap } from 'immutable';
import { createSelector } from 'reselect';

import type { RootState } from '../store';

// TODO(trintrogycerin): All the selectors in this file expose 'unknown' to the user which is not
// very helpful. This could be improved by moving the state slices that back the
// selectors to Immutable Records instead of Immutable Maps.
type Account = ImmutableMap<string, unknown>;
type AccountCounters = ImmutableMap<string, number>;
type AccountRelationship = unknown;

const getAccountBase = (state: RootState, id: string): Account | null => {
  return state.accounts.get(id, null);
};

const getAccountCounters = (
  state: RootState,
  id: string
): AccountCounters | null => {
  // TODO(trinitroglycerin): This slice is not typed, so we need to convert the type
  // to avoid complaints about 'any'
  const counters = state.accounts_counters as ImmutableMap<
    string,
    AccountCounters
  >;

  return counters.get(id, null);
};

const getAccountRelationship = (
  state: RootState,
  id: string
): AccountRelationship | null => {
  // TODO(trinitroglycerin): This slice is not typed, so we need to convert the type
  // to avoid complaints about 'any'
  const rels = state.relationships as ImmutableMap<string, AccountRelationship>;
  return rels.get(id, null);
};

const getAccountMoved = (state: RootState, id: string): Account | undefined => {
  const moved = state.accounts.getIn([id, 'moved'], null) as string | null;
  if (moved === null) {
    return undefined;
  }

  return state.accounts.get(moved);
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

      if (counters !== null) {
        base = base.merge(counters);
      }

      return base.withMutations((map) => {
        map.set('relationship', relationship);
        map.set('moved', moved);
      });
    }
  );
};
