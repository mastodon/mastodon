import { Record as ImmutableRecord } from 'immutable';
import { createSelector } from 'reselect';

import { accountDefaultValues } from 'mastodon/models/account';
import type { Account, AccountShape } from 'mastodon/models/account';
import type { RootState } from 'mastodon/store';

interface AccountCountersShape {
  following_count: number;
  followers_count: number;
  statuses_count: number;
}

const getAccountBase = (state: RootState, id: string) =>
  state.accounts.get(id, null);

const getAccountCounters = (state: RootState, id: string) =>
  state.accounts_counters.get(id, null);

const getAccountRelationship = (state: RootState, id: string) =>
  state.relationships.get(id, null);

const getAccountMoved = (state: RootState, id: string) => {
  const movedToId = state.accounts.get(id)?.moved;

  if (!movedToId) return undefined;

  return state.accounts.get(movedToId);
};

interface FullAccountShape
  extends Omit<AccountShape, 'moved'>,
    AccountCountersShape {
  relationship: unknown;
  moved: Account | null;
}

const FullAccountFactory = ImmutableRecord<FullAccountShape>({
  ...accountDefaultValues,
  relationship: null,
  followers_count: 0,
  following_count: 0,
  statuses_count: 0,
});

export function makeGetAccount() {
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

      return FullAccountFactory(base).withMutations((fullAccount) => {
        fullAccount.merge(counters);
        fullAccount.set('relationship', relationship);
        fullAccount.set('moved', moved ?? null);
      });
    },
  );
}
