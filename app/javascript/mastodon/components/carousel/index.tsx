import { useCallback, useLayoutEffect, useMemo, useRef, useState } from 'react';
import type {
  ComponentPropsWithoutRef,
  ComponentType,
  ReactElement,
  ReactNode,
} from 'react';

import type { MessageDescriptor } from 'react-intl';
import { defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';

import { usePrevious } from '@dnd-kit/utilities';
import { animated, useSpring } from '@react-spring/web';
import { useDrag } from '@use-gesture/react';

import type { CarouselPaginationProps } from './pagination';
import { CarouselPagination } from './pagination';

import './styles.scss';

const defaultMessages = defineMessages({
  previous: { id: 'lightbox.previous', defaultMessage: 'Previous' },
  next: { id: 'lightbox.next', defaultMessage: 'Next' },
  current: {
    id: 'carousel.current',
    defaultMessage: '<sr>Slide</sr> {current, number} / {max, number}',
  },
  slide: {
    id: 'carousel.slide',
    defaultMessage: 'Slide {current, number} of {max, number}',
  },
});

export type MessageKeys = keyof typeof defaultMessages;

export interface CarouselSlideProps {
  id: string | number;
}

export type RenderSlideFn<
  SlideProps extends CarouselSlideProps = CarouselSlideProps,
> = (item: SlideProps, active: boolean, index: number) => ReactElement;

export interface CarouselProps<
  SlideProps extends CarouselSlideProps = CarouselSlideProps,
> {
  items: SlideProps[];
  renderItem: RenderSlideFn<SlideProps>;
  onChangeSlide?: (index: number, ref: Element) => void;
  paginationComponent?: ComponentType<CarouselPaginationProps> | null;
  paginationProps?: Partial<CarouselPaginationProps>;
  messages?: Record<MessageKeys, MessageDescriptor>;
  emptyFallback?: ReactNode;
  classNamePrefix?: string;
  slideClassName?: string;
}

export const Carousel = <
  SlideProps extends CarouselSlideProps = CarouselSlideProps,
>({
  items,
  renderItem,
  onChangeSlide,
  paginationComponent: Pagination = CarouselPagination,
  paginationProps = {},
  messages = defaultMessages,
  children,
  emptyFallback = null,
  className,
  classNamePrefix = 'carousel',
  slideClassName,
  ...wrapperProps
}: CarouselProps<SlideProps> & ComponentPropsWithoutRef<'div'>) => {
  // Handle slide change
  const [slideIndex, setSlideIndex] = useState(0);
  const wrapperRef = useRef<HTMLDivElement>(null);
  // Handle slide heights
  const [currentSlideHeight, setCurrentSlideHeight] = useState(
    () => wrapperRef.current?.scrollHeight ?? 0,
  );
  const previousSlideHeight = usePrevious(currentSlideHeight);
  const handleSlideChange = useCallback(
    (direction: number) => {
      setSlideIndex((prev) => {
        const max = items.length - 1;
        let newIndex = prev + direction;
        if (newIndex < 0) {
          newIndex = max;
        } else if (newIndex > max) {
          newIndex = 0;
        }

        const slide = wrapperRef.current?.children[newIndex];
        if (slide) {
          setCurrentSlideHeight(slide.scrollHeight);
          if (slide instanceof HTMLElement) {
            onChangeSlide?.(newIndex, slide);
          }
        }

        return newIndex;
      });
    },
    [items.length, onChangeSlide],
  );

  const observerRef = useRef<ResizeObserver | null>(null);
  observerRef.current ??= new ResizeObserver(() => {
    handleSlideChange(0);
  });

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
  const bind = useDrag(
    ({ swipe: [swipeX] }) => {
      handleSlideChange(swipeX * -1); // Invert swipe as swiping left loads the next slide.
    },
    { pointer: { capture: false } },
  );
  const handlePrev = useCallback(() => {
    handleSlideChange(-1);
    // We're focusing on the wrapper as the child slides can potentially be inert.
    // Because of that, only the active slide can be focused anyway.
    wrapperRef.current?.focus();
  }, [handleSlideChange]);
  const handleNext = useCallback(() => {
    handleSlideChange(1);
    wrapperRef.current?.focus();
  }, [handleSlideChange]);

  const intl = useIntl();

  if (items.length === 0) {
    return emptyFallback;
  }

  return (
    <div
      {...bind()}
      aria-roledescription='carousel'
      role='region'
      className={classNames(classNamePrefix, className)}
      {...wrapperProps}
    >
      <div className={`${classNamePrefix}__header`}>
        {children}
        {Pagination && items.length > 1 && (
          <Pagination
            current={slideIndex}
            max={items.length}
            onNext={handleNext}
            onPrev={handlePrev}
            className={`${classNamePrefix}__pagination`}
            messages={messages}
            {...paginationProps}
          />
        )}
      </div>

      <animated.div
        className={`${classNamePrefix}__slides`}
        ref={wrapperRef}
        style={wrapperStyles}
        aria-label={intl.formatMessage(messages.slide, {
          current: slideIndex + 1,
          max: items.length,
        })}
        tabIndex={-1}
      >
        {items.map((itemsProps, index) => (
          <CarouselSlideWrapper<SlideProps>
            item={itemsProps}
            renderItem={renderItem}
            observer={observerRef.current}
            index={index}
            key={`slide-${itemsProps.id}`}
            className={classNames(`${classNamePrefix}__slide`, slideClassName, {
              active: index === slideIndex,
            })}
            active={index === slideIndex}
          />
        ))}
      </animated.div>
    </div>
  );
};

type CarouselSlideWrapperProps<SlideProps extends CarouselSlideProps> = {
  observer: ResizeObserver | null;
  className: string;
  active: boolean;
  item: SlideProps;
  index: number;
} & Pick<CarouselProps<SlideProps>, 'renderItem'>;

const CarouselSlideWrapper = <SlideProps extends CarouselSlideProps>({
  observer,
  className,
  active,
  renderItem,
  item,
  index,
}: CarouselSlideWrapperProps<SlideProps>) => {
  const handleRef = useCallback(
    (instance: HTMLDivElement | null) => {
      if (observer && instance) {
        observer.observe(instance);
      }
    },
    [observer],
  );

  const children = useMemo(
    () => renderItem(item, active, index),
    [renderItem, item, active, index],
  );

  return (
    <div
      ref={handleRef}
      className={className}
      role='group'
      aria-roledescription='slide'
      inert={active ? undefined : ''}
      data-index={index}
    >
      {children}
    </div>
  );
};
