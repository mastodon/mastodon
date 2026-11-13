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

const domParser = new DOMParser();

const getContent = (html: string, selectorName: string) => {
  let content = '';
  const selectors = domParser
    .parseFromString(html, 'text/html')
    .querySelectorAll(selectorName);
  for (const selector of selectors) {
    const selectorText = selector.textContent.trim() || '';

    if (selectorText.length > 0) {
      content += ` ${selectorText}`;
    }
  }
  return content;
};

export const getStatusContent = (html: string) => getContent(html, 'p');
