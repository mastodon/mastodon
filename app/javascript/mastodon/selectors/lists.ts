import type { Map as ImmutableMap, List as ImmutableList } from 'immutable';

import type { List } from 'mastodon/models/list';
import { createAppSelector } from 'mastodon/store';

const getLists = createAppSelector(
  [(state) => state.lists],
  (lists: ImmutableMap<string, List | null>): ImmutableList<List> =>
    lists.toList().filter((item: List | null): item is List => !!item),
);

export const getOrderedLists = createAppSelector(
  [(state) => getLists(state)],
  (lists) =>
    lists.sort((a: List, b: List) => a.title.localeCompare(b.title)).toArray(),
);
