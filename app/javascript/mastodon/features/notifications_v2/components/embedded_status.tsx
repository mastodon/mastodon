import { useAppSelector } from 'mastodon/store';
import BarChart4BarsIcon from '@/material-icons/400-24px/bar_chart_4_bars.svg?react';
import PhotoLibraryIcon from '@/material-icons/400-24px/photo_library.svg?react';
import { Icon } from 'mastodon/components/icon';
import { FormattedMessage } from 'react-intl';
import { Avatar } from 'mastodon/components/avatar';
import { DisplayName } from 'mastodon/components/display_name';

export const EmbeddedStatus = ({ statusId }) => {
  const status = useAppSelector(state => state.getIn(['statuses', statusId]));
  const account = useAppSelector(state => state.getIn(['accounts', status?.get('account')]));

  if (!status) {
    return null;
  }

  const content = { __html: status.get('contentHtml') };

  return (
    <div className='notification-group__embedded-status'>
      <div className='notification-group__embedded-status__account'>
        <Avatar account={account} size={16} />
        <DisplayName account={account} />
      </div>

      <div className='notification-group__embedded-status__content reply-indicator__content translate' dangerouslySetInnerHTML={content} />

      {(status.get('poll') || status.get('media_attachments').size > 0) && (
        <div className='notification-group__embedded-status__attachments reply-indicator__attachments'>
          {status.get('poll') && <><Icon icon={BarChart4BarsIcon} /><FormattedMessage id='reply_indicator.poll' defaultMessage='Poll' /></>}
          {status.get('media_attachments').size > 0 && <><Icon icon={PhotoLibraryIcon} /><FormattedMessage id='reply_indicator.attachments' defaultMessage='{count, plural, one {# attachment} other {# attachments}}' values={{ count: status.get('media_attachments').size }} /></>}
        </div>
      )}
    </div>
  );
}
