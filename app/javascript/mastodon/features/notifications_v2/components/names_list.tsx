import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import { useAppSelector } from 'mastodon/store';

export const NamesList: React.FC<{ accountIds: string[]; total: number }> = ({
  accountIds,
  total,
}) => {
  const lastAccountId = accountIds[0] ?? '0';
  const account = useAppSelector((state) => state.accounts.get(lastAccountId));

  if (!account) return null;

  const displayedName = (
    <Link
      to={`/@${account.acct}`}
      title={`@${account.acct}`}
      data-hover-card-account={account.id}
    >
      <bdi dangerouslySetInnerHTML={{ __html: account.display_name_html }} />
    </Link>
  );

  if (total === 1) {
    return displayedName;
  }

  return (
    <FormattedMessage
      id='name_and_others'
      defaultMessage='{name} and {count, plural, one {# other} other {# others}}'
      values={{ name: displayedName, count: total - 1 }}
    />
  );
};
