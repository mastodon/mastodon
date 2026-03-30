import React, {
  useContext,
  useEffect,
  useImperativeHandle,
  useRef,
} from 'react';

import { defaultShouldUpdateScroll } from './default_should_update_scroll';
import type { ShouldUpdateScrollFn } from './default_should_update_scroll';
import { ScrollBehaviorContext } from './scroll_context';

interface ScrollContainerProps {
  /**
   * This key must be static for the element & not change
   * while the component is mounted.
   */
  scrollKey: string;
  shouldUpdateScroll?: ShouldUpdateScrollFn;
  childRef?: React.ForwardedRef<HTMLElement | undefined>;
  children: React.ReactElement;
}

/**
 * `ScrollContainer` is used to manage the scroll position of elements on the page
 * that can be scrolled independently of the page body.
 * This component is a port of the unmaintained https://github.com/ytase/react-router-scroll/
 */

export const ScrollContainer: React.FC<ScrollContainerProps> = ({
  children,
  scrollKey,
  childRef,
  shouldUpdateScroll = defaultShouldUpdateScroll,
}) => {
  const scrollBehaviorContext = useContext(ScrollBehaviorContext);

  const containerRef = useRef<HTMLElement>();

  /**
   * If a childRef is passed, sync it with the containerRef. This
   * is necessary because in this component's return statement,
   * we're overwriting the immediate child component's ref prop.
   */
  useImperativeHandle(childRef, () => containerRef.current, []);

  /**
   * Register/unregister scrollable element with ScrollBehavior
   */
  useEffect(() => {
    if (!scrollBehaviorContext || !containerRef.current) {
      return;
    }

    scrollBehaviorContext.registerElement(
      scrollKey,
      containerRef.current,
      (prevLocation, location) => {
        // Hack to allow accessing scrollBehavior._stateStorage
        return shouldUpdateScroll.call(
          scrollBehaviorContext.scrollBehavior,
          prevLocation,
          location,
        );
      },
    );

    return () => {
      scrollBehaviorContext.unregisterElement(scrollKey);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return React.Children.only(
    React.cloneElement(children, { ref: containerRef }),
  );
};
