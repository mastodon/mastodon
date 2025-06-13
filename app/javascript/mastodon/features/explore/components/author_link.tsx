import { Link } from 'react-router-dom';

import { Avatar } from 'mastodon/components/avatar';
import { useAppSelector } from 'mastodon/store';

export const AuthorLink: React.FC<{
  accountId: string;
}> = ({ accountId }) => {
  const account = useAppSelector((state) => state.accounts.get(accountId));

  if (!account) {
    return null;
  }

  return (
    <Link
      to={`/@${account.acct}`}
      className='story__details__shared__author-link'
      data-hover-card-account={accountId}
    >
      <Avatar account={account} size={16} />
      <bdi dangerouslySetInnerHTML={{ __html: account.display_name_html }} />
    </Link>
  );
};
