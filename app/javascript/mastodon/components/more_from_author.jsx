import PropTypes from 'prop-types';

import { FormattedMessage } from 'react-intl';

import { IconLogo } from 'mastodon/components/logo';
import { AuthorLink } from 'mastodon/features/explore/components/author_link';

export const MoreFromAuthor = ({ accountId }) => (
  <div className='more-from-author'>
    <IconLogo />
    <FormattedMessage id='link_preview.more_from_author' defaultMessage='More from {name}' values={{ name: <AuthorLink accountId={accountId} /> }} />
  </div>
);

MoreFromAuthor.propTypes = {
  accountId: PropTypes.string.isRequired,
};
