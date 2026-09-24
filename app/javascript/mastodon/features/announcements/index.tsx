import { useCallback } from 'react';
import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import type { Map, List } from 'immutable';

import { XIcon } from '@phosphor-icons/react';

import elephantUIPlane from '@/images/elephant_ui_plane.svg';
import { hideAnnouncements } from '@/mastodon/actions/announcements';
import { IconButton } from '@/mastodon/components/button/redesign';
import type { RenderSlideFn } from '@/mastodon/components/carousel';
import { Carousel } from '@/mastodon/components/carousel';
import { CustomEmojiProvider } from '@/mastodon/components/emoji/context';
import { useCustomEmojis } from '@/mastodon/hooks/useCustomEmojis';
import { mascot } from '@/mastodon/initial_state';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';
import { isRedesignEnabled } from '@/mastodon/utils/environment';

import type { IAnnouncement } from './announcement';
import { Announcement } from './announcement';

const announcementSelector = createAppSelector(
  [(state) => state.announcements as Map<string, List<Map<string, unknown>>>],
  (announcements) =>
    ((announcements.get('items')?.toJS() as IAnnouncement[] | undefined) ?? [])
      .map((announcement) => ({ announcement, id: announcement.id }))
      .toReversed(),
);

export const Announcements: FC = () => {
  const dispatch = useAppDispatch();
  const announcements = useAppSelector(announcementSelector);
  const emojis = useCustomEmojis();

  const closeAnnouncements = useCallback(() => {
    dispatch(hideAnnouncements());
  }, [dispatch]);

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
        src={mascot ?? elephantUIPlane}
      />

      {isRedesignEnabled() && (
        <IconButton
          icon={XIcon}
          onClick={closeAnnouncements}
          size='sm'
          variant='ghost'
          className='announcements__close-button'
        >
          <FormattedMessage id='lightbox.close' defaultMessage='Close' />
        </IconButton>
      )}

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
