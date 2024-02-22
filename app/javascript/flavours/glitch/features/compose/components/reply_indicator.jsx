import { FormattedMessage } from 'react-intl';

import { useSelector } from 'react-redux';

import BarChart4BarsIcon from '@/material-icons/400-24px/bar_chart_4_bars.svg?react';
import PhotoLibraryIcon from '@/material-icons/400-24px/photo_library.svg?react';
import { Avatar } from 'flavours/glitch/components/avatar';
import { DisplayName } from 'flavours/glitch/components/display_name';
import { Icon } from 'flavours/glitch/components/icon';
import { Permalink } from 'flavours/glitch/components/permalink';

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

      <Permalink href={account.get('url')} to={`/@${account.get('acct')}`} className='detailed-status__display-avatar'>
        <Avatar account={account} size={46} />
      </Permalink>

      <div className='reply-indicator__main'>
        <Permalink href={account.get('url')} to={`/@${account.get('acct')}`} className='detailed-status__display-name'>
          <DisplayName account={account} />
        </Permalink>

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
