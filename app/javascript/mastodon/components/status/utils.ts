import type { AnyStatusShape } from '@/mastodon/models/status';

export function statusLink({
  account,
  id,
}: Pick<AnyStatusShape, 'account' | 'id'>) {
  return `/@${typeof account === 'string' ? account : account.acct}/${id}`;
}
