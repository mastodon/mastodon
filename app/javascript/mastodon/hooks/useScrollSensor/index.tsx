import type { ComponentProps, CSSProperties } from 'react';
import { useLayoutEffect, useRef, useState } from 'react';

import classNames from 'classnames';

import classes from './styles.module.scss';

interface ScrollSensorOptions extends ComponentProps<'div'> {
  placement?: 'top' | 'bottom';
  tolerance?: number;
  // Use document scrolling as reference
  global?: boolean;
}

/**
 * Returns a `sensor` element and whether it's visible inside of its
 * nearest scrollable parent element (or the document if `global` is set).
 *
 * Useful for detecting whether a scrollable element was scrolled
 * and whether sticky elements are "stuck" (while we wait for CSS
 * scroll queries to be more widely supported) without having to rely on
 * scroll event listeners or resize and mutation observers.
 *
 * Place the sensor element directly into the scroll parent as the first
 * or last element, and ensure that the scroll parent uses a `position`
 * value other than `static`.
 */
export const useScrollSensor = ({
  placement = 'top',
  tolerance,
  global,
  className,
  style,
  ...props
}: ScrollSensorOptions = {}) => {
  const [isInViewport, setIsInViewport] = useState(true);
  const sensorRef = useRef<HTMLDivElement>(null);
  const observerRef = useRef<IntersectionObserver>(null);

  useLayoutEffect(() => {
    const sensor = sensorRef.current;

    if (!sensor) return;

    // Assign the IntersectionObserver to a ref so we don't
    // need to re-create it when the effect reruns
    if (!observerRef.current) {
      // This could be enhanced with a util to actually walk up
      // the tree to find the nearest scrollable element. For now,
      // it assumes the immediate parent as the scroll root.
      const root = global ? null : sensor.parentElement;

      observerRef.current = new IntersectionObserver(
        ([entry]) => {
          if (entry) {
            setIsInViewport(entry.isIntersecting);
          }
        },
        {
          root,
        },
      );
    }

    observerRef.current.observe(sensor);

    return () => {
      if (observerRef.current) {
        observerRef.current.unobserve(sensor);
      }
    };
  }, [sensorRef, global]);

  const sensorStyle = tolerance
    ? ({
        ...style,
        '--tolerance': `${tolerance}px`,
      } as CSSProperties)
    : style;

  const sensor = (
    <div
      {...props}
      className={classNames(classes.sensor, className)}
      style={sensorStyle}
      data-placement={placement}
      ref={sensorRef}
    />
  );

  return {
    sensor,
    isInViewport,
  };
};
