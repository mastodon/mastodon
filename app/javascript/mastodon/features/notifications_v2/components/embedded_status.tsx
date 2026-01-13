import { useCallback, useRef } from 'react';

import { FormattedMessage } from 'react-intl';

import { useHistory } from 'react-router-dom';

import type { List as ImmutableList, RecordOf } from 'immutable';

import type { ApiMentionJSON } from '@/mastodon/api_types/statuses';
import { AnimateEmojiProvider } from '@/mastodon/components/emoji/context';
import BarChart4BarsIcon from '@/material-icons/400-24px/bar_chart_4_bars.svg?react';
import PhotoLibraryIcon from '@/material-icons/400-24px/photo_library.svg?react';
import { toggleStatusSpoilers } from 'mastodon/actions/statuses';
import { Avatar } from 'mastodon/components/avatar';
import { ContentWarning } from 'mastodon/components/content_warning';
import { DisplayName } from 'mastodon/components/display_name';
import { Icon } from 'mastodon/components/icon';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { EmbeddedStatusContent } from './embedded_status_content';

export type Mention = RecordOf<ApiMentionJSON>;

export const EmbeddedStatus: React.FC<{ statusId: string }> = ({
  statusId,
}) => {
  const history = useHistory();
  const clickCoordinatesRef = useRef<[number, number] | null>();
  const dispatch = useAppDispatch();

  const status = useAppSelector((state) => state.statuses.get(statusId));

  const account = useAppSelector((state) =>
    state.accounts.get(status?.get('account') as string),
  );

  const handleMouseDown = useCallback<React.MouseEventHandler<HTMLDivElement>>(
    ({ clientX, clientY }) => {
      clickCoordinatesRef.current = [clientX, clientY];
    },
    [clickCoordinatesRef],
  );

  const handleMouseUp = useCallback<React.MouseEventHandler<HTMLDivElement>>(
    ({ clientX, clientY, target, button, ctrlKey, metaKey }) => {
      const [startX, startY] = clickCoordinatesRef.current ?? [0, 0];
      const [deltaX, deltaY] = [
        Math.abs(clientX - startX),
        Math.abs(clientY - startY),
      ];

      let element: HTMLDivElement | null = target as HTMLDivElement;

      while (element) {
        if (
          element.localName === 'button' ||
          element.localName === 'a' ||
          element.localName === 'label'
        ) {
          return;
        }

        element = element.parentNode as HTMLDivElement | null;
      }

      if (deltaX + deltaY < 5 && account) {
        const path = `/@${account.acct}/${statusId}`;

        if (button === 0 && !(ctrlKey || metaKey)) {
          history.push(path);
        } else if (button === 1 || (button === 0 && (ctrlKey || metaKey))) {
          window.open(path, '_blank', 'noopener');
        }
      }

      clickCoordinatesRef.current = null;
    },
    [clickCoordinatesRef, statusId, account, history],
  );

  const handleContentWarningClick = useCallback(() => {
    dispatch(toggleStatusSpoilers(statusId));
  }, [dispatch, statusId]);

  if (!status) {
    return null;
  }

  // Assign status attributes to variables with a forced type, as status is not yet properly typed
  const hasContentWarning = !!status.get('spoiler_text');
  const poll = status.get('poll');
  const expanded = !status.get('hidden') || !hasContentWarning;
  const mediaAttachmentsSize = (
    status.get('media_attachments') as ImmutableList<unknown>
  ).size;

  return (
    <AnimateEmojiProvider
      className='notification-group__embedded-status'
      role='button'
      tabIndex={-1}
      onMouseDown={handleMouseDown}
      onMouseUp={handleMouseUp}
    >
      <div className='notification-group__embedded-status__account'>
        <Avatar account={account} size={16} />
        <DisplayName account={account} />
      </div>

      <ContentWarning
        status={status}
        onClick={handleContentWarningClick}
        expanded={expanded}
      />

      {(!hasContentWarning || expanded) && (
        <EmbeddedStatusContent
          className='notification-group__embedded-status__content reply-indicator__content translate'
          status={status}
        />
      )}

      {expanded && (poll || mediaAttachmentsSize > 0) && (
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
    </AnimateEmojiProvider>
  );
};
