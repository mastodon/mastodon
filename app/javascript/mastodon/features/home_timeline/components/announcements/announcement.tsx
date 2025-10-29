import { useEffect, useState } from 'react';
import type { FC } from 'react';

import { FormattedDate, FormattedMessage } from 'react-intl';

import type { ApiAnnouncementJSON } from '@/mastodon/api_types/announcements';
import { AnimateEmojiProvider } from '@/mastodon/components/emoji/context';
import { EmojiHTML } from '@/mastodon/components/emoji/html';

import { ReactionsBar } from './reactions';

export interface IAnnouncement extends ApiAnnouncementJSON {
  contentHtml: string;
}

interface AnnouncementProps {
  announcement: IAnnouncement;
  active?: boolean;
}

export const Announcement: FC<AnnouncementProps> = ({
  announcement,
  active,
}) => {
  const [unread, setUnread] = useState(!announcement.read);
  useEffect(() => {
    // Only update `unread` marker once the announcement is out of view
    if (!active && unread !== !announcement.read) {
      setUnread(!announcement.read);
    }
  }, [announcement.read, active, unread]);

  return (
    <AnimateEmojiProvider>
      <strong className='announcements__range'>
        <FormattedMessage
          id='announcement.announcement'
          defaultMessage='Announcement'
        />
        <span>
          {' · '}
          <Timestamp announcement={announcement} />
        </span>
      </strong>

      <EmojiHTML
        className='announcements__content translate'
        htmlString={announcement.contentHtml}
        extraEmojis={announcement.emojis}
      />

      <ReactionsBar reactions={announcement.reactions} id={announcement.id} />

      {unread && <span className='announcements__unread' />}
    </AnimateEmojiProvider>
  );
};

const Timestamp: FC<Pick<AnnouncementProps, 'announcement'>> = ({
  announcement,
}) => {
  const startsAt = announcement.starts_at && new Date(announcement.starts_at);
  const endsAt = announcement.ends_at && new Date(announcement.ends_at);
  const now = new Date();
  const hasTimeRange = startsAt && endsAt;
  const skipTime = announcement.all_day;

  if (hasTimeRange) {
    const skipYear =
      startsAt.getFullYear() === endsAt.getFullYear() &&
      endsAt.getFullYear() === now.getFullYear();
    const skipEndDate =
      startsAt.getDate() === endsAt.getDate() &&
      startsAt.getMonth() === endsAt.getMonth() &&
      startsAt.getFullYear() === endsAt.getFullYear();
    return (
      <>
        <FormattedDate
          value={startsAt}
          year={
            skipYear || startsAt.getFullYear() === now.getFullYear()
              ? undefined
              : 'numeric'
          }
          month='short'
          day='2-digit'
          hour={skipTime ? undefined : '2-digit'}
          minute={skipTime ? undefined : '2-digit'}
        />{' '}
        -{' '}
        <FormattedDate
          value={endsAt}
          year={
            skipYear || endsAt.getFullYear() === now.getFullYear()
              ? undefined
              : 'numeric'
          }
          month={skipEndDate ? undefined : 'short'}
          day={skipEndDate ? undefined : '2-digit'}
          hour={skipTime ? undefined : '2-digit'}
          minute={skipTime ? undefined : '2-digit'}
        />
      </>
    );
  }
  const publishedAt = new Date(announcement.published_at);
  return (
    <FormattedDate
      value={publishedAt}
      year={
        publishedAt.getFullYear() === now.getFullYear() ? undefined : 'numeric'
      }
      month='short'
      day='2-digit'
      hour={skipTime ? undefined : '2-digit'}
      minute={skipTime ? undefined : '2-digit'}
    />
  );
};
