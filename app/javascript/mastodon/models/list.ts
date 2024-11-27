import type { RecordOf } from 'immutable';
import { Record } from 'immutable';

import type { ApiListJSON } from 'mastodon/api_types/lists';

interface ListShape extends Required<Omit<ApiListJSON, 'account'>> {
  account_id?: string;
}

export type List = RecordOf<ListShape>;

const ListFactory = Record<ListShape>({
  id: '',
  url: '',
  title: '',
  slug: '',
  description: '',
  type: 'private_list',
  exclusive: false,
  replies_policy: 'list',
  account_id: undefined,
  created_at: '',
  updated_at: '',
});

export const createList = (serverJSON: ApiListJSON): List => {
  const { account, ...listJSON } = serverJSON;

  return ListFactory({
    ...listJSON,
    account_id: account?.id,
  });
};
