import type { AccountShape } from '@/mastodon/models/account';
import type { AccountStatusShape } from '@/mastodon/models/status';

export function statusLink({
  account,
  id,
}: Pick<AccountStatusShape, 'account' | 'id'>) {
  return `/@${account.acct}/${id}`;
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
