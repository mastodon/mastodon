import PropTypes from 'prop-types';

import { Avatar } from 'mastodon/components/avatar';
import { useAppSelector } from 'mastodon/store';
import { LinkedDisplayName } from '@/mastodon/components/display_name';

export const AuthorLink = ({ accountId }) => {
  const account = useAppSelector(state => state.getIn(['accounts', accountId]));

  if (!account) {
    return null;
  }

  return (
    <LinkedDisplayName displayProps={{account}} className='story__details__shared__author-link'>
      <Avatar account={account} size={16} />
    </LinkedDisplayName>
  );
};

AuthorLink.propTypes = {
  accountId: PropTypes.string.isRequired,
};
