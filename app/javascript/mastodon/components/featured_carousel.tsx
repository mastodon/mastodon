import type { ComponentPropsWithRef } from 'react';
import {
  useCallback,
  useEffect,
  useLayoutEffect,
  useRef,
  useState,
  useId,
} from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import type { Map as ImmutableMap } from 'immutable';
import { List as ImmutableList } from 'immutable';

import type { AnimatedProps } from '@react-spring/web';
import { animated, useSpring } from '@react-spring/web';
import { useDrag } from '@use-gesture/react';

import { expandAccountFeaturedTimeline } from '@/mastodon/actions/timelines';
import { Icon } from '@/mastodon/components/icon';
import { IconButton } from '@/mastodon/components/icon_button';
import { StatusQuoteManager } from '@/mastodon/components/status_quoted';
import { usePrevious } from '@/mastodon/hooks/usePrevious';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import ChevronLeftIcon from '@/material-icons/400-24px/chevron_left.svg?react';
import ChevronRightIcon from '@/material-icons/400-24px/chevron_right.svg?react';
import PushPinIcon from '@/material-icons/400-24px/push_pin.svg?react';

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
  const accessibilityId = useId();

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
  const wrapperRef = useRef<HTMLDivElement>(null);
  const handleSlideChange = useCallback(
    (direction: number) => {
      setSlideIndex((prev) => {
        const max = pinnedStatuses.size - 1;
        let newIndex = prev + direction;
        if (newIndex < 0) {
          newIndex = max;
        } else if (newIndex > max) {
          newIndex = 0;
        }
        const slide = wrapperRef.current?.children[newIndex];
        if (slide) {
          setCurrentSlideHeight(slide.scrollHeight);
        }
        return newIndex;
      });
    },
    [pinnedStatuses.size],
  );

  // Handle slide heights
  const [currentSlideHeight, setCurrentSlideHeight] = useState(
    wrapperRef.current?.scrollHeight ?? 0,
  );
  const previousSlideHeight = usePrevious(currentSlideHeight);
  const observerRef = useRef<ResizeObserver>(
    new ResizeObserver(() => {
      handleSlideChange(0);
    }),
  );
  const wrapperStyles = useSpring({
    x: `-${slideIndex * 100}%`,
    height: currentSlideHeight,
    // Don't animate from zero to the height of the initial slide
    immediate: !previousSlideHeight,
  });
  useLayoutEffect(() => {
    // Update slide height when the component mounts
    if (currentSlideHeight === 0) {
      handleSlideChange(0);
    }
  }, [currentSlideHeight, handleSlideChange]);

  // Handle swiping animations
  const bind = useDrag(({ swipe: [swipeX] }) => {
    handleSlideChange(swipeX * -1); // Invert swipe as swiping left loads the next slide.
  });
  const handlePrev = useCallback(() => {
    handleSlideChange(-1);
  }, [handleSlideChange]);
  const handleNext = useCallback(() => {
    handleSlideChange(1);
  }, [handleSlideChange]);

  if (!accountId || pinnedStatuses.isEmpty()) {
    return null;
  }

  return (
    <div
      className='featured-carousel'
      {...bind()}
      aria-roledescription='carousel'
      aria-labelledby={`${accessibilityId}-title`}
      role='region'
    >
      <div className='featured-carousel__header'>
        <h4
          className='featured-carousel__title'
          id={`${accessibilityId}-title`}
        >
          <Icon id='thumb-tack' icon={PushPinIcon} />
          <FormattedMessage
            id='featured_carousel.header'
            defaultMessage='{count, plural, one {Pinned Post} other {Pinned Posts}}'
            values={{ count: pinnedStatuses.size }}
          />
        </h4>
        {pinnedStatuses.size > 1 && (
          <>
            <IconButton
              title={intl.formatMessage(messages.previous)}
              icon='chevron-left'
              iconComponent={ChevronLeftIcon}
              onClick={handlePrev}
            />
            <span aria-live='polite'>
              <FormattedMessage
                id='featured_carousel.post'
                defaultMessage='Post'
              >
                {(text) => <span className='sr-only'>{text}</span>}
              </FormattedMessage>
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
          <FeaturedCarouselItem
            key={`f-${statusId}`}
            data-index={index}
            aria-label={intl.formatMessage(messages.slide, {
              index: index + 1,
              total: pinnedStatuses.size,
            })}
            statusId={statusId}
            observer={observerRef.current}
            active={index === slideIndex}
          />
        ))}
      </animated.div>
    </div>
  );
};

interface FeaturedCarouselItemProps {
  statusId: string;
  active: boolean;
  observer: ResizeObserver;
}

const FeaturedCarouselItem: React.FC<
  FeaturedCarouselItemProps & AnimatedProps<ComponentPropsWithRef<'div'>>
> = ({ statusId, active, observer, ...props }) => {
  const handleRef = useCallback(
    (instance: HTMLDivElement | null) => {
      if (instance) {
        observer.observe(instance);
      }
    },
    [observer],
  );

  return (
    <animated.div
      className='featured-carousel__slide'
      // @ts-expect-error inert in not in this version of React
      inert={!active ? 'true' : undefined}
      aria-roledescription='slide'
      role='group'
      ref={handleRef}
      {...props}
    >
      <StatusQuoteManager id={statusId} contextType='account' withCounters />
    </animated.div>
  );
};
