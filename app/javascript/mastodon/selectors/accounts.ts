import type { Map as ImmutableMap } from 'immutable';
import { createSelector } from 'reselect';

import type { Account } from 'mastodon/reducers/accounts';
import type { AccountCounters } from 'mastodon/reducers/accounts_counters';
import type { Map } from 'mastodon/utils/immutable';

import type { RootState } from '../store';

type AccountRelationship = unknown;

const getAccountBase = (state: RootState, id: string): Map<Account> | null => {
  return state.accounts.get(id, null);
};

const getAccountCounters = (
  state: RootState,
  id: string
): Map<AccountCounters> | null => {
  return state.accounts_counters.get(id, null);
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

const getAccountMoved = (
  state: RootState,
  id: string
): Map<{ id: string }> | undefined => {
  const moved = state.accounts.getIn([id, 'moved'], null) as string | null;
  if (moved === null) {
    return undefined;
  }

  return state.accounts.get(moved);
};

// TODO(trinitroglycerin): Obviously this is a temporary name
interface ExposedAccountType extends Account, AccountCounters {
  relationship: AccountRelationship;
  moved: Map<{ id: string }> | null;
}

// TODO(trinitroglycerin): I separated this out from makeGetAccount() to ease type diagnosis,
// but I am pretty sure this must be within makeGetAccount() to ensure module splitting works correctly.
//
// Including this file would cause a side effect if createSelector() is used at a base level, and since it's
// re-exported from selectors/index.js, any file which includes selectors/index.js will cause this function to be executed.
//
// I'm not convinced this is actually a problem in the real world as Mastodon is distributed mostly as one bundle, and this is
// a core feature of Mastodon, but I'm not familiar enough with the codebase to do this without this disclaimer.
// TODO(trinitroglycerin): While this function does return a map containing Account, it also includes
// the computed properties 'relationship' (from getAccountRelationship) and 'moved' (from getAccountMoved).
//
// The details hare are currently hidden by the fact we use an Immutable Map, but we should strongly consider
// using an Immutable Record with a type that correctly indicates the type of the value returned, because
// these computed properties are not on the Account type in the initial_state file.
export const getAccount: (
  state: RootState,
  id: string
) => Map<ExposedAccountType> | null = createSelector(
  [getAccountBase, getAccountCounters, getAccountRelationship, getAccountMoved],
  (base, counters, relationship, moved) => {
    if (base === null) {
      return null;
    }

    let out = base;
    if (counters !== null) {
      out = base.merge(counters);
    }

    return out.withMutations<ExposedAccountType>((map) => {
      map.set('relationship', relationship);
      map.set('moved', moved ?? null);
    });
  }
);

export const makeGetAccount = () => getAccount;
