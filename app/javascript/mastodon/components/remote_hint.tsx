import PropTypes from 'prop-types';

import { FormattedMessage } from 'react-intl';

import { useAppSelector } from 'mastodon/store';

import { TimelineHint } from './timeline_hint';

interface RemoteHintProps {
  accountId?: string;
}

export const RemoteHint: React.FC<RemoteHintProps> = ({ accountId }) => {
  const account = useAppSelector((state) =>
    accountId ? state.accounts.get(accountId) : undefined,
  );
  if (!account || !account.url || account.acct !== account.username) {
    return null;
  }
  const domain = account.acct ? account.acct.split('@')[1] : undefined;

  return (
    <TimelineHint
      url={account.url}
      message={
        <FormattedMessage
          id='hints.profiles.posts_may_be_missing'
          defaultMessage='Some posts from this profile may be missing.'
        />
      }
      label={
        <FormattedMessage
          id='hints.profiles.see_more_posts'
          defaultMessage='See more posts on {domain}'
          values={{ domain: <strong>{domain}</strong> }}
        />
      }
    />
  );
};

RemoteHint.propTypes = {
  accountId: PropTypes.string.isRequired,
};
