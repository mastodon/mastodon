import { useCallback, useEffect, useRef, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import type { Map as ImmutableMap } from 'immutable';
import { List as ImmutableList } from 'immutable';

import { animated, useSpring } from '@react-spring/web';
import { useDrag } from '@use-gesture/react';

import { expandAccountFeaturedTimeline } from '@/mastodon/actions/timelines';
import { IconButton } from '@/mastodon/components/icon_button';
import StatusContainer from '@/mastodon/containers/status_container';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import ChevronLeftIcon from '@/material-icons/400-24px/chevron_left.svg?react';
import ChevronRightIcon from '@/material-icons/400-24px/chevron_right.svg?react';

const messages = defineMessages({
  previous: { id: 'featured_carousel.previous', defaultMessage: 'Previous' },
  next: { id: 'featured_carousel.next', defaultMessage: 'Next' },
  slide: {
    id: 'featured_carousel.slide',
    defaultMessage: '{index} of {total}',
  },
});

export const FeaturedCarousel: React.FC<{
  accountId: string;
  tagged?: string;
}> = ({ accountId, tagged }) => {
  const intl = useIntl();

  // Load pinned statuses
  const dispatch = useAppDispatch();
  useEffect(() => {
    if (accountId) {
      void dispatch(expandAccountFeaturedTimeline(accountId, { tagged }));
    }
  }, [accountId, dispatch, tagged]);
  const pinnedStatuses = useAppSelector(
    (state) =>
      (state.timelines as ImmutableMap<string, unknown>).getIn(
        [`account:${accountId}:pinned${tagged ? `:${tagged}` : ''}`, 'items'],
        ImmutableList(),
      ) as ImmutableList<string>,
  );

  // Handle slide change
  const [slideIndex, setSlideIndex] = useState(0);
  const handleSlideChange = useCallback(
    (direction: number) => {
      const max = pinnedStatuses.size - 1;
      setSlideIndex((prev) => {
        const newIndex = prev + direction;
        if (newIndex < 0) {
          return max;
        } else if (newIndex > max) {
          return 0;
        }
        return newIndex;
      });
    },
    [pinnedStatuses.size],
  );

  // Handle swiping animations
  const { x } = useSpring({ x: `-${slideIndex * 100}%` });
  const bind = useDrag(({ swipe: [swipeX] }) => {
    handleSlideChange(swipeX * -1); // Invert swipe as swiping left loads the next slide.
  });
  const handlePrev = useCallback(() => {
    handleSlideChange(-1);
  }, [handleSlideChange]);
  const handleNext = useCallback(() => {
    handleSlideChange(1);
  }, [handleSlideChange]);

  // Handle wrapper height animation
  const [wrapperStyles, wrapperSpringApi] = useSpring(() => ({
    height: 100,
  }));
  const wrapperRef = useRef<HTMLDivElement>(null);
  const wrapperEle = wrapperRef.current;
  useEffect(() => {
    if (!wrapperEle) {
      return;
    }
    const currentSlideEle = wrapperEle.querySelector(
      `[data-index="${slideIndex}"] > div`,
    );

    if (!currentSlideEle) {
      return;
    }
    const height = currentSlideEle.scrollHeight;
    if (!height) {
      return;
    }

    void wrapperSpringApi.start({ height });
  }, [slideIndex, wrapperSpringApi, wrapperEle]);

  if (!accountId || pinnedStatuses.isEmpty()) {
    return null;
  }

  return (
    <div
      className='featured-carousel'
      {...bind()}
      aria-roledescription='carousel'
      aria-labelledby='featured-carousel-title'
      role='region'
    >
      <div className='featured-carousel__header'>
        <h4 className='featured-carousel__title' id='featured-carousel-title'>
          {pinnedStatuses.size > 1 ? (
            <FormattedMessage
              id='featured_carousel.header.plural'
              defaultMessage='Pinned Posts'
            />
          ) : (
            <FormattedMessage
              id='featured_carousel.header.single'
              defaultMessage='Pinned Post'
            />
          )}
        </h4>
        {pinnedStatuses.size > 1 && (
          <>
            <IconButton
              title={intl.formatMessage(messages.previous)}
              icon='chevron-left'
              iconComponent={ChevronLeftIcon}
              onClick={handlePrev}
            />
            <FormattedMessage id='featured_carousel.post' defaultMessage='Post'>
              {(text) => <span className='sr-only'>{text}</span>}
            </FormattedMessage>
            <span aria-live='polite'>
              {slideIndex + 1} / {pinnedStatuses.size}
            </span>
            <IconButton
              title={intl.formatMessage(messages.next)}
              icon='chevron-right'
              iconComponent={ChevronRightIcon}
              onClick={handleNext}
            />
          </>
        )}
      </div>
      <animated.div
        className='featured-carousel__slides'
        ref={wrapperRef}
        style={wrapperStyles}
        aria-atomic='false'
        aria-live='polite'
      >
        {pinnedStatuses.map((statusId, index) => (
          <animated.div
            key={`f-${statusId}`}
            style={{ x }}
            className='featured-carousel__slide'
            data-index={index}
            aria-label={intl.formatMessage(messages.slide, {
              index: index + 1,
              total: pinnedStatuses.size,
            })}
            aria-roledescription='slide'
            role='group'
          >
            <StatusContainer
              // @ts-expect-error inferred props are wrong
              id={statusId}
              contextType='account'
            />
          </animated.div>
        ))}
      </animated.div>
    </div>
  );
};
