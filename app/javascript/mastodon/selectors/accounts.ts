import type { Map as ImmutableMap } from 'immutable';
import { Record as ImmutableRecord, List as ImmutableList } from 'immutable';

import { me } from 'mastodon/initial_state';
import { accountDefaultValues } from 'mastodon/models/account';
import type { Account, AccountShape } from 'mastodon/models/account';
import type { Relationship } from 'mastodon/models/relationship';
import { createAppSelector } from 'mastodon/store';
import type { RootState } from 'mastodon/store';

import type { ApiHashtagJSON } from '../api_types/tags';

const getAccountBase = (state: RootState, id: string) =>
  state.accounts.get(id, null);

const getAccountRelationship = (state: RootState, id: string) =>
  state.relationships.get(id, null);

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
  return createAppSelector(
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

export const getAccountHidden = createAppSelector(
  [
    (state, id: string) => state.accounts.get(id)?.hidden,
    (state, id: string) =>
      state.relationships.get(id)?.following ||
      state.relationships.get(id)?.requested,
    (_, id: string) => id === me,
  ],
  (hidden, followingOrRequested, isSelf) => {
    return hidden && !(isSelf || followingOrRequested);
  },
);

export const getAccountFamiliarFollowers = createAppSelector(
  [
    (state) => state.accounts,
    (state, id: string) => state.accounts_familiar_followers[id],
  ],
  (accounts, accounts_familiar_followers) => {
    if (!accounts_familiar_followers) return null;
    return accounts_familiar_followers
      .map((id) => accounts.get(id))
      .filter((f) => !!f);
  },
);

export type TagType = Omit<
  ApiHashtagJSON,
  'history' | 'following' | 'featured'
> & {
  accountId: string;
  statuses_count: number;
  last_status_at: string;
};

export const selectAccountFeaturedTags = createAppSelector(
  [(state) => state.user_lists, (_, accountId: string) => accountId],
  (user_lists, accountId) => {
    const list = user_lists.getIn(
      ['featured_tags', accountId, 'items'],
      ImmutableList(),
    ) as ImmutableList<ImmutableMap<string, string | null>>;
    return list.toArray().map(
      (tag) =>
        ({
          id: tag.get('id') as string,
          name: tag.get('name') as string,
          url: tag.get('url') as string,
          accountId: tag.get('accountId') as string,
          statuses_count: Number.parseInt(
            tag.get('statuses_count') as string,
            10,
          ),
          last_status_at: tag.get('last_status_at') as string,
        }) satisfies TagType,
    );
  },
);
