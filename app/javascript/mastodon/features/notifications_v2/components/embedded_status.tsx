import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { useHistory } from 'react-router-dom';

import type { List as ImmutableList, RecordOf } from 'immutable';

import BarChart4BarsIcon from '@/material-icons/400-24px/bar_chart_4_bars.svg?react';
import PhotoLibraryIcon from '@/material-icons/400-24px/photo_library.svg?react';
import { Avatar } from 'mastodon/components/avatar';
import { DisplayName } from 'mastodon/components/display_name';
import { Icon } from 'mastodon/components/icon';
import type { Status } from 'mastodon/models/status';
import { useAppSelector } from 'mastodon/store';

import { EmbeddedStatusContent } from './embedded_status_content';

export type Mention = RecordOf<{ url: string; acct: string }>;

export const EmbeddedStatus: React.FC<{ statusId: string }> = ({
  statusId,
}) => {
  const history = useHistory();

  const status = useAppSelector(
    (state) => state.statuses.get(statusId) as Status | undefined,
  );

  const account = useAppSelector((state) =>
    state.accounts.get(status?.get('account') as string),
  );

  const handleClick = useCallback(() => {
    if (!account) return;

    history.push(`/@${account.acct}/${statusId}`);
  }, [statusId, account, history]);

  if (!status) {
    return null;
  }

  // Assign status attributes to variables with a forced type, as status is not yet properly typed
  const contentHtml = status.get('contentHtml') as string;
  const poll = status.get('poll');
  const language = status.get('language') as string;
  const mentions = status.get('mentions') as ImmutableList<Mention>;
  const mediaAttachmentsSize = (
    status.get('media_attachments') as ImmutableList<unknown>
  ).size;

  return (
    <div className='notification-group__embedded-status'>
      <div className='notification-group__embedded-status__account'>
        <Avatar account={account} size={16} />
        <DisplayName account={account} />
      </div>

      <EmbeddedStatusContent
        className='notification-group__embedded-status__content reply-indicator__content translate'
        content={contentHtml}
        language={language}
        mentions={mentions}
        onClick={handleClick}
      />

      {(poll || mediaAttachmentsSize > 0) && (
        <div className='notification-group__embedded-status__attachments reply-indicator__attachments'>
          {!!poll && (
            <>
              <Icon icon={BarChart4BarsIcon} id='bar-chart-4-bars' />
              <FormattedMessage
                id='reply_indicator.poll'
                defaultMessage='Poll'
              />
            </>
          )}
          {mediaAttachmentsSize > 0 && (
            <>
              <Icon icon={PhotoLibraryIcon} id='photo-library' />
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
