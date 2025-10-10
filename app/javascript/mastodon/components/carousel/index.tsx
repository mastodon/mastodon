import { useCallback, useId, useLayoutEffect, useRef, useState } from 'react';
import type {
  ComponentPropsWithoutRef,
  ComponentType,
  FC,
  PropsWithChildren,
  ReactNode,
} from 'react';

import classNames from 'classnames';

import { usePrevious } from '@dnd-kit/utilities';
import { animated, useSpring } from '@react-spring/web';
import { useDrag } from '@use-gesture/react';

import type { CarouselPaginationProps } from './pagination';
import { CarouselPagination } from './pagination';

import './styles.scss';

export interface CarouselSlideProps {
  id: string | number;
  active?: boolean;
}

type CarouselSlideComponent<SlideProps> = ComponentType<
  SlideProps & CarouselSlideProps
>;

export interface CarouselProps<SlideProps>
  extends ComponentPropsWithoutRef<'div'> {
  items: SlideProps[];
  slideComponent: CarouselSlideComponent<SlideProps>;
  slideClassName?: string;
  pageComponent?: ComponentType<CarouselPaginationProps>;
  emptyFallback?: ReactNode;
  classNamePrefix?: string;
  onChangeSlide?: (index: number) => void;
}

export const Carousel = <SlideProps extends CarouselSlideProps>({
  items,
  pageComponent: Pagination = CarouselPagination,
  slideComponent: Slide,
  children,
  emptyFallback = null,
  className,
  slideClassName,
  classNamePrefix = 'carousel',
  onChangeSlide,
  ...wrapperProps
}: CarouselProps<SlideProps>) => {
  const accessibilityId = useId();

  // Handle slide change
  const [slideIndex, setSlideIndex] = useState(0);
  const wrapperRef = useRef<HTMLDivElement>(null);
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
        }
        onChangeSlide?.(newIndex);
        return newIndex;
      });
    },
    [items.length, onChangeSlide],
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
  const bind = useDrag(
    ({ swipe: [swipeX] }) => {
      handleSlideChange(swipeX * -1); // Invert swipe as swiping left loads the next slide.
    },
    { pointer: { capture: false } },
  );
  const handlePrev = useCallback(() => {
    handleSlideChange(-1);
  }, [handleSlideChange]);
  const handleNext = useCallback(() => {
    handleSlideChange(1);
  }, [handleSlideChange]);

  if (!items.length) {
    return emptyFallback;
  }

  return (
    <div
      {...bind()}
      aria-roledescription='carousel'
      aria-labelledby={`${accessibilityId}-title`}
      role='region'
      className={classNames(classNamePrefix, className)}
      {...wrapperProps}
    >
      <div className={`${classNamePrefix}__header`}>
        {children}
        <Pagination
          current={slideIndex}
          max={items.length}
          onNext={handleNext}
          onPrev={handlePrev}
          className={`${classNamePrefix}__pagination`}
        />
      </div>

      <animated.div
        className={`${classNamePrefix}__slides`}
        ref={wrapperRef}
        style={wrapperStyles}
        aria-atomic='false'
        aria-live='polite'
      >
        {items.map((props, index) => (
          <CarouselSlideWrapper
            observer={observerRef.current}
            key={`slide-${props.id}`}
            className={classNames(`${classNamePrefix}__slide`, slideClassName, {
              active: index === slideIndex,
            })}
          >
            <Slide
              {...props}
              key={`slide-${props.id}`}
              data-index={index}
              active={index === slideIndex}
            />
          </CarouselSlideWrapper>
        ))}
      </animated.div>
    </div>
  );
};

type CarouselSlideWrapperProps = Required<
  PropsWithChildren<{ observer: ResizeObserver; className: string }>
>;

const CarouselSlideWrapper: FC<CarouselSlideWrapperProps> = ({
  observer,
  children,
  className,
}) => {
  const handleRef = useCallback(
    (instance: HTMLDivElement | null) => {
      if (instance) {
        observer.observe(instance);
      }
    },
    [observer],
  );
  return (
    <div ref={handleRef} className={className} aria-roledescription='slide'>
      {children}
    </div>
  );
};
