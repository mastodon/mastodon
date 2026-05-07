import { useCallback } from 'react';
import type { FC } from 'react';

import type { Map, List } from 'immutable';

import elephantUIPlane from '@/images/elephant_ui_plane.svg';
import type { RenderSlideFn } from '@/mastodon/components/carousel';
import { Carousel } from '@/mastodon/components/carousel';
import { CustomEmojiProvider } from '@/mastodon/components/emoji/context';
import { mascot } from '@/mastodon/initial_state';
import { createAppSelector, useAppSelector } from '@/mastodon/store';

import type { IAnnouncement } from './announcement';
import { Announcement } from './announcement';

const announcementSelector = createAppSelector(
  [(state) => state.announcements as Map<string, List<Map<string, unknown>>>],
  (announcements) =>
    ((announcements.get('items')?.toJS() as IAnnouncement[] | undefined) ?? [])
      .map((announcement) => ({ announcement, id: announcement.id }))
      .toReversed(),
);

// --- IMAGE SRC VALIDATION ---
// Only allow http(s) or data URLs as a defense-in-depth
function isSafeImageSrc(url: string | undefined | null): boolean {
  if (!url) return false;
  try {
    const parsed = new URL(url, window.location.origin);
    return (
      parsed.protocol === 'http:' ||
      parsed.protocol === 'https:' ||
      parsed.protocol === 'data:'
    );
  } catch {
    return false;
  }
}

export const Announcements: FC = () => {
  const announcements = useAppSelector(announcementSelector);
  const emojis = useAppSelector((state) => state.custom_emojis);

  const renderSlide: RenderSlideFn<{
    id: string;
    announcement: IAnnouncement;
  }> = useCallback(
    (item, active) => (
      <Announcement
        announcement={item.announcement}
        active={active}
        key={item.id}
      />
    ),
    [],
  );

  if (announcements.length === 0) {
    return null;
  }

  return (
    <div className='announcements__root'>
      <img
        className='announcements__mastodon'
        alt=''
        draggable='false'
        // Only use mascot if it's a safe http(s) or data URL, else fallback to static
        src={isSafeImageSrc(mascot) ? mascot! : elephantUIPlane}
      />

      <CustomEmojiProvider emojis={emojis}>
        <Carousel
          classNamePrefix='announcements'
          renderItem={renderSlide}
          items={announcements}
        />
      </CustomEmojiProvider>
    </div>
  );
};
