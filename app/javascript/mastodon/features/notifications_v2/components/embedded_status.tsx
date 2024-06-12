import { FormattedMessage } from 'react-intl';

import type { List } from 'immutable';

import BarChart4BarsIcon from '@/material-icons/400-24px/bar_chart_4_bars.svg?react';
import PhotoLibraryIcon from '@/material-icons/400-24px/photo_library.svg?react';
import { Avatar } from 'mastodon/components/avatar';
import { DisplayName } from 'mastodon/components/display_name';
import { Icon } from 'mastodon/components/icon';
import type { Status } from 'mastodon/models/status';
import { useAppSelector } from 'mastodon/store';

export const EmbeddedStatus: React.FC<{ statusId: string }> = ({
  statusId,
}) => {
  const status = useAppSelector(
    (state) => state.statuses.get(statusId) as Status | undefined,
  );
  const account = useAppSelector((state) =>
    state.accounts.get(status?.get('account') as string),
  );

  if (!status) {
    return null;
  }

  // Assign status attributes to variables with a forced type, as status is not yet properly typed
  const contentHtml = status.get('contentHtml') as string;
  const poll = status.get('poll');
  const mediaAttachmentsSize = (
    status.get('media_attachments') as List<unknown>
  ).size;

  const content = { __html: contentHtml };

  return (
    <div className='notification-group__embedded-status'>
      <div className='notification-group__embedded-status__account'>
        <Avatar account={account} size={16} />
        <DisplayName account={account} />
      </div>

      <div
        className='notification-group__embedded-status__content reply-indicator__content translate'
        dangerouslySetInnerHTML={content}
      />

      {(poll || mediaAttachmentsSize > 0) && (
        <div className='notification-group__embedded-status__attachments reply-indicator__attachments'>
          {!!poll && (
            <>
              <Icon icon={BarChart4BarsIcon} />
              <FormattedMessage
                id='reply_indicator.poll'
                defaultMessage='Poll'
              />
            </>
          )}
          {mediaAttachmentsSize > 0 && (
            <>
              <Icon icon={PhotoLibraryIcon} />
              <FormattedMessage
                id='reply_indicator.attachments'
                defaultMessage='{count, plural, one {# attachment} other {# attachments}}'
                values={{ count: mediaAttachmentsSize }}
              />
            </>
          )}
        </div>
      )}
    </div>
  );
};
