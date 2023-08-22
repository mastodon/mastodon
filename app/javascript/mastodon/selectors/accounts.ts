import { Record as ImmutableRecord } from 'immutable';
import { createSelector } from 'reselect';

import { accountDefaultValues } from 'mastodon/models/account';
import type { Account, AccountShape } from 'mastodon/models/account';
import type { Relationship } from 'mastodon/models/relationship';
import type { RootState } from 'mastodon/store';

const getAccountBase = (state: RootState, id: string) =>
  state.accounts.get(id, null);

const getAccountRelationship = (state: RootState, id: string) =>
  // TODO(renchap): update this when `Relationship` is typed
  // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-call
  state.relationships.get(id, null) as Relationship;

const getAccountMoved = (state: RootState, id: string) => {
  const movedToId = state.accounts.get(id)?.moved;

  if (!movedToId) return undefined;

  return state.accounts.get(movedToId);
};

interface FullAccountShape extends Omit<AccountShape, 'moved'> {
  relationship: Relationship | null;
  moved: Account | null;
}

const FullAccountFactory = ImmutableRecord<FullAccountShape>({
  ...accountDefaultValues,
  moved: null,
  relationship: null,
});

export function makeGetAccount() {
  return createSelector(
    [getAccountBase, getAccountRelationship, getAccountMoved],
    (base, relationship, moved) => {
      if (base === null) {
        return null;
      }

      return FullAccountFactory(base)
        .set('relationship', relationship)
        .set('moved', moved ?? null);
    },
  );
}
