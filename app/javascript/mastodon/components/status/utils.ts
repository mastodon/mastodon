import type { AccountShape } from '@/mastodon/models/account';
import type { AnyStatusShape } from '@/mastodon/models/status';

export function statusLink({
  account,
  id,
}: Pick<AnyStatusShape, 'account' | 'id'>) {
  return `/@${typeof account === 'string' ? account : account.acct}/${id}`;
}

export function accountStatusLinkProps(
  account: Pick<AccountShape, 'acct' | 'id'>,
) {
  return {
    to: {
      pathname: `/@${account.acct}`,
      state: { reference: 'status' },
    },
    title: `@${account.acct}`,
    'data-id': account.id,
    'data-hover-card-account': account.id,
    'data-hover-card-reference': 'status',
  };
}
