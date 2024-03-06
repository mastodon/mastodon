import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import { useSelector } from 'react-redux';

import BarChart4BarsIcon from '@/material-icons/400-24px/bar_chart_4_bars.svg?react';
import PhotoLibraryIcon from '@/material-icons/400-24px/photo_library.svg?react';
import { Avatar } from 'mastodon/components/avatar';
import { DisplayName } from 'mastodon/components/display_name';
import { Icon } from 'mastodon/components/icon';

export const ReplyIndicator = () => {
  const inReplyToId = useSelector(state => state.getIn(['compose', 'in_reply_to']));
  const status = useSelector(state => state.getIn(['statuses', inReplyToId]));
  const account = useSelector(state => state.getIn(['accounts', status?.get('account')]));

  if (!status) {
    return null;
  }

  const content = { __html: status.get('contentHtml') };

  return (
    <div className='reply-indicator'>
      <div className='reply-indicator__line' />

      <Link to={`/@${account.get('acct')}`} className='detailed-status__display-avatar'>
        <Avatar account={account} size={46} />
      </Link>

      <div className='reply-indicator__main'>
        <Link to={`/@${account.get('acct')}`} className='detailed-status__display-name'>
          <DisplayName account={account} />
        </Link>

        <div className='reply-indicator__content translate' dangerouslySetInnerHTML={content} />

        {(status.get('poll') || status.get('media_attachments').size > 0) && (
          <div className='reply-indicator__attachments'>
            {status.get('poll') && <><Icon icon={BarChart4BarsIcon} /><FormattedMessage id='reply_indicator.poll' defaultMessage='Poll' /></>}
            {status.get('media_attachments').size > 0 && <><Icon icon={PhotoLibraryIcon} /><FormattedMessage id='reply_indicator.attachments' defaultMessage='{count, plural, one {# attachment} other {# attachments}}' values={{ count: status.get('media_attachments').size }} /></>}
          </div>
        )}
      </div>
    </div>
  );
};
