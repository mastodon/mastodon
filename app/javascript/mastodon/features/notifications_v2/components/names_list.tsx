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
    <Link to={`/@${account.get('acct')}`} title={`@${account.get('acct')}`}>
      <bdi
        dangerouslySetInnerHTML={{ __html: account.get('display_name_html') }}
      />
    </Link>
  );

  if (total === 1) {
    return displayedName;
  }

  return (
    <FormattedMessage
      id=''
      defaultMessage='{name} and {count, plural, one {# other} other {# others}}'
      values={{ name: displayedName, count: total - 1 }}
    />
  );
};
