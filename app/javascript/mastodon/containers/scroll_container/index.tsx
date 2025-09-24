import React, { useContext, useEffect, useRef } from 'react';

import { defaultShouldUpdateScroll } from './default_should_update_scroll';
import type { ShouldUpdateScrollFn } from './default_should_update_scroll';
import { ScrollBehaviorContext } from './scroll_context';

interface ScrollContainerProps {
  scrollKey: string;
  shouldUpdateScroll?: ShouldUpdateScrollFn;
  children: React.ReactElement;
}

export const ScrollContainer: React.FC<ScrollContainerProps> = ({
  children,
  scrollKey,
  shouldUpdateScroll = defaultShouldUpdateScroll,
}) => {
  const scrollBehaviorContext = useContext(ScrollBehaviorContext);

  const containerRef = useRef<HTMLElement>();

  // Register element when component mounts
  useEffect(() => {
    // Ensure scroll behavior context and container ref exist
    if (!scrollBehaviorContext || !containerRef.current) {
      return;
    }

    // Handle scroll update logic
    const handleShouldUpdateScroll: ShouldUpdateScrollFn = (
      prevLocation,
      location,
    ) => {
      // Hack to allow accessing scrollBehavior._stateStorage
      return shouldUpdateScroll.call(
        scrollBehaviorContext.scrollBehavior,
        prevLocation,
        location,
      );
    };

    // Register the element with scroll behavior
    scrollBehaviorContext.registerElement(
      scrollKey,
      containerRef.current,
      handleShouldUpdateScroll,
    );

    // Cleanup function to unregister element
    return () => {
      scrollBehaviorContext.unregisterElement(scrollKey);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return React.Children.only(
    React.cloneElement(children, { ref: containerRef }),
  );
};
