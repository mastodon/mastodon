import {
  useCallback,
  useEffect,
  useLayoutEffect,
  useRef,
  useState,
} from 'react';
import type {
  ComponentPropsWithoutRef,
  ComponentType,
  FC,
  PropsWithChildren,
  ReactElement,
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
}

export type RenderSlideFn<
  SlideProps extends CarouselSlideProps = CarouselSlideProps,
> = (item: SlideProps, active: boolean, index: number) => ReactElement;

export interface CarouselProps<
  SlideProps extends CarouselSlideProps = CarouselSlideProps,
> {
  items: SlideProps[];
  renderItem: RenderSlideFn<SlideProps>;
  onChangeSlide?: (index: number) => void;
  paginationComponent?: ComponentType<CarouselPaginationProps> | null;
  paginationProps?: Partial<CarouselPaginationProps>;
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
            {...paginationProps}
          />
        )}
      </div>

      <animated.div
        className={`${classNamePrefix}__slides`}
        ref={wrapperRef}
        style={wrapperStyles}
      >
        {items.map((itemsProps, index) => (
          <CarouselSlideWrapper
            observer={observerRef.current}
            key={`slide-${itemsProps.id}`}
            className={classNames(`${classNamePrefix}__slide`, slideClassName, {
              active: index === slideIndex,
            })}
            active={index === slideIndex}
          >
            {renderItem(itemsProps, index === slideIndex, index)}
          </CarouselSlideWrapper>
        ))}
      </animated.div>
    </div>
  );
};

type CarouselSlideWrapperProps = Required<
  PropsWithChildren<{
    observer: ResizeObserver;
    className: string;
    active: boolean;
  }>
>;

const CarouselSlideWrapper: FC<CarouselSlideWrapperProps> = ({
  observer,
  children,
  className,
  active,
}) => {
  const slideRef = useRef<HTMLDivElement>();

  const handleRef = useCallback(
    (instance: HTMLDivElement | null) => {
      if (instance) {
        observer.observe(instance);
        slideRef.current = instance;
      }
    },
    [observer],
  );

  useEffect(() => {
    if (slideRef.current && active) {
      slideRef.current.focus();
    }
  }, [active]);

  return (
    <div
      ref={handleRef}
      className={className}
      role='group'
      aria-roledescription='slide'
      // @ts-expect-error inert in not in this version of React
      inert={active ? 'true' : undefined}
    >
      {children}
    </div>
  );
};
