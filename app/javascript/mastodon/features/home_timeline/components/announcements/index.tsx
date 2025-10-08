import { useCallback, useState } from 'react';
import type { FC } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import type { Map, List } from 'immutable';

import ReactSwipeableViews from 'react-swipeable-views';

import elephantUIPlane from '@/images/elephant_ui_plane.svg';
import { CustomEmojiProvider } from '@/mastodon/components/emoji/context';
import { IconButton } from '@/mastodon/components/icon_button';
import LegacyAnnouncements from '@/mastodon/features/getting_started/containers/announcements_container';
import { mascot, reduceMotion } from '@/mastodon/initial_state';
import { createAppSelector, useAppSelector } from '@/mastodon/store';
import { isModernEmojiEnabled } from '@/mastodon/utils/environment';
import ChevronLeftIcon from '@/material-icons/400-24px/chevron_left.svg?react';
import ChevronRightIcon from '@/material-icons/400-24px/chevron_right.svg?react';

import type { IAnnouncement } from './announcement';
import { Announcement } from './announcement';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
  previous: { id: 'lightbox.previous', defaultMessage: 'Previous' },
  next: { id: 'lightbox.next', defaultMessage: 'Next' },
});

const announcementSelector = createAppSelector(
  [(state) => state.announcements as Map<string, List<Map<string, unknown>>>],
  (announcements) =>
    (announcements.get('items')?.toJS() as IAnnouncement[] | undefined) ?? [],
);

export const ModernAnnouncements: FC = () => {
  const intl = useIntl();

  const announcements = useAppSelector(announcementSelector);
  const emojis = useAppSelector((state) => state.custom_emojis);

  const [index, setIndex] = useState(0);
  const handleChangeIndex = useCallback(
    (idx: number) => {
      setIndex(idx % announcements.length);
    },
    [announcements.length],
  );
  const handleNextIndex = useCallback(() => {
    setIndex((prevIndex) => (prevIndex + 1) % announcements.length);
  }, [announcements.length]);
  const handlePrevIndex = useCallback(() => {
    setIndex((prevIndex) =>
      prevIndex === 0 ? announcements.length - 1 : prevIndex - 1,
    );
  }, [announcements.length]);

  if (announcements.length === 0) {
    return null;
  }

  return (
    <div className='announcements'>
      <img
        className='announcements__mastodon'
        alt=''
        draggable='false'
        src={mascot ?? elephantUIPlane}
      />

      <div className='announcements__container'>
        <CustomEmojiProvider emojis={emojis}>
          <ReactSwipeableViews
            animateHeight
            animateTransitions={!reduceMotion}
            index={index}
            onChangeIndex={handleChangeIndex}
          >
            {announcements
              .map((announcement, idx) => (
                <Announcement
                  key={announcement.id}
                  announcement={announcement}
                  selected={index === idx}
                />
              ))
              .reverse()}
          </ReactSwipeableViews>
        </CustomEmojiProvider>

        {announcements.length > 1 && (
          <div className='announcements__pagination'>
            <IconButton
              disabled={announcements.length === 1}
              title={intl.formatMessage(messages.previous)}
              icon='chevron-left'
              iconComponent={ChevronLeftIcon}
              onClick={handlePrevIndex}
            />
            <span>
              {index + 1} / {announcements.length}
            </span>
            <IconButton
              disabled={announcements.length === 1}
              title={intl.formatMessage(messages.next)}
              icon='chevron-right'
              iconComponent={ChevronRightIcon}
              onClick={handleNextIndex}
            />
          </div>
        )}
      </div>
    </div>
  );
};

export const Announcements = isModernEmojiEnabled()
  ? ModernAnnouncements
  : LegacyAnnouncements;
