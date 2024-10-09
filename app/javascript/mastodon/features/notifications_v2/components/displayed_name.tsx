import { useAppSelector } from 'mastodon/store';
import Permalink from 'mastodon/components/permalink';

export const DisplayedName: React.FC<{
  accountIds: string[];
}> = ({ accountIds }) => {
  const lastAccountId = accountIds[0] ?? '0';
  const account = useAppSelector((state) => state.accounts.get(lastAccountId));

  if (!account) return null;

  return (
    <Permalink
      href={account.url}
      to={`/@${account.acct}`}
      title={`@${account.acct}`}
      data-hover-card-account={account.id}
    >
      <bdi dangerouslySetInnerHTML={{ __html: account.display_name_html }} />
    </Permalink>
  );
};
