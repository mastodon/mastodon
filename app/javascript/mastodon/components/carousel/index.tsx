import { useCallback, useId, useRef, useState } from 'react';
import type { ComponentPropsWithoutRef, ComponentType, ReactNode } from 'react';

import { animated, useSpring } from '@react-spring/web';
import { useDrag } from '@use-gesture/react';

import type { CarouselPaginationProps } from './pagination';
import { CarouselPagination } from './pagination';

export interface CarouselSlideProps {
  id: string | number;
  active?: boolean;
}

type CarouselSlideComponent<SlideProps> = ComponentType<
  SlideProps & CarouselSlideProps
>;

interface CarouselProps<SlideProps> extends ComponentPropsWithoutRef<'div'> {
  items: SlideProps[];
  slideComponent: CarouselSlideComponent<SlideProps>;
  pageComponent?: ComponentType<CarouselPaginationProps>;
  slidesWrapperClassName?: string;
  emptyFallback?: ReactNode;
}

export const Carousel = <SlideProps extends CarouselSlideProps>({
  items,
  pageComponent: Pagination = CarouselPagination,
  slideComponent: Slide,
  children,
  emptyFallback = null,
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
        return newIndex;
      });
    },
    [items.length],
  );
  const wrapperStyles = useSpring({
    x: `-${slideIndex * 100}%`,
  });

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

  if (!items.length) {
    return emptyFallback;
  }

  return (
    <div
      {...bind()}
      aria-roledescription='carousel'
      aria-labelledby={`${accessibilityId}-title`}
      role='region'
      {...wrapperProps}
    >
      {children}
      <Pagination
        current={slideIndex}
        max={items.length}
        onNext={handleNext}
        onPrev={handlePrev}
      />
      <animated.div
        className='carousel__slides'
        ref={wrapperRef}
        style={wrapperStyles}
        aria-atomic='false'
        aria-live='polite'
      >
        {items.map((props, index) => (
          <Slide
            {...props}
            key={`slide-${props.id}`}
            data-index={index}
            active={index === slideIndex}
          />
        ))}
      </animated.div>
    </div>
  );
};
