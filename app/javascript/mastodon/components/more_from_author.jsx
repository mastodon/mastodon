import PropTypes from 'prop-types';

import { FormattedMessage } from 'react-intl';

import { AuthorLink } from 'mastodon/features/explore/components/author_link';

export const MoreFromAuthor = ({ accountId }) => (
  <div className='more-from-author'>
    <svg viewBox='0 0 79 79' className='logo logo--icon' role='img'>
      <use xlinkHref='#logo-symbol-icon' />
    </svg>

    <FormattedMessage id='link_preview.more_from_author' defaultMessage='More from {name}' values={{ name: <AuthorLink accountId={accountId} /> }} />
  </div>
);

MoreFromAuthor.propTypes = {
  accountId: PropTypes.string.isRequired,
};
