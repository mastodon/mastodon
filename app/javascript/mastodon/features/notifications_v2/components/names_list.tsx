import { useAppSelector } from 'mastodon/store';
import { FormattedMessage } from 'react-intl';
import { Link } from 'react-router-dom';

export const NamesList = ({ accountIds, total }) => {
  const lastAccountId = accountIds[0];
  const account = useAppSelector(state => state.getIn(['accounts', lastAccountId]));
  const displayedName = <Link to={`/@${account.get('acct')}`} title={`@${account.get('acct')}`}><bdi dangerouslySetInnerHTML={{ __html: account.get('display_name_html') }} /></Link>;

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
