import type { RecordOf } from 'immutable';
import { Record } from 'immutable';

import type { ApiListJSON } from 'mastodon/api_types/lists';

type ListShape = Required<ApiListJSON>; // no changes from server shape
export type List = RecordOf<ListShape>;

const ListFactory = Record<ListShape>({
  id: '',
  title: '',
  exclusive: false,
  replies_policy: 'list',
});

export function createList(attributes: Partial<ListShape>) {
  return ListFactory(attributes);
}
