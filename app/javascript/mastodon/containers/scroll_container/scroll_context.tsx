import React, { useEffect, useMemo, useRef, useState } from 'react';

import { useLocation, useHistory } from 'react-router-dom';

import type { LocationBase } from 'scroll-behavior';
import ScrollBehavior from 'scroll-behavior';

import type {
  LocationState,
  MastodonLocation,
} from 'mastodon/components/router';
import { usePrevious } from 'mastodon/hooks/usePrevious';

import { defaultShouldUpdateScroll } from './default_should_update_scroll';
import type { ShouldUpdateScrollFn } from './default_should_update_scroll';
import { SessionStorage } from './state_storage';

type ScrollBehaviorInstance = InstanceType<
  typeof ScrollBehavior<LocationBase, MastodonLocation>
>;

export interface ScrollBehaviorContextType {
  registerElement: (
    key: string,
    element: HTMLElement,
    shouldUpdateScroll: (
      prevLocationContext: MastodonLocation | null,
      locationContext: MastodonLocation,
    ) => boolean,
  ) => void;
  unregisterElement: (key: string) => void;
  scrollBehavior?: ScrollBehaviorInstance;
}

export const ScrollBehaviorContext =
  React.createContext<ScrollBehaviorContextType | null>(null);

interface ScrollContextProps {
  shouldUpdateScroll?: ShouldUpdateScrollFn;
  children: React.ReactElement;
}

/**
 * A top-level wrapper that provides the app with an instance of the
 * ScrollBehavior object. scroll-behavior is a library for managing the
 * scroll position of a single-page app in the same way the browser would
 * normally do for a multi-page app. This means it'll scroll back to top
 * when navigating to a new page, and will restore the scroll position
 * when navigating e.g. using `history.back`.
 * The library keeps a record of scroll positions in session storage.
 *
 * This component is a port of the unmaintained https://github.com/ytase/react-router-scroll/
 */

export const ScrollContext: React.FC<ScrollContextProps> = ({
  children,
  shouldUpdateScroll = defaultShouldUpdateScroll,
}) => {
  const location = useLocation<LocationState>();
  const history = useHistory<LocationState>();

  /**
   * Keep the current location in a mutable ref so that ScrollBehavior's
   * `getCurrentLocation` can access it without having to recreate the
   * whole ScrollBehavior object
   */
  const currentLocationRef = useRef(location);
  useEffect(() => {
    currentLocationRef.current = location;
  }, [location]);

  /**
   * Initialise ScrollBehavior object once – using state rather
   * than a ref to simplify the types and ensure it's defined immediately.
   */
  const [scrollBehavior] = useState(
    (): ScrollBehaviorInstance =>
      new ScrollBehavior({
        addNavigationListener: history.listen.bind(history),
        stateStorage: new SessionStorage(),
        getCurrentLocation: () =>
          currentLocationRef.current as unknown as LocationBase,
        shouldUpdateScroll: (
          prevLocationContext: MastodonLocation | null,
          locationContext: MastodonLocation,
        ) =>
          // Hack to allow accessing scrollBehavior._stateStorage
          shouldUpdateScroll.call(
            // eslint-disable-next-line react-hooks/immutability
            scrollBehavior,
            prevLocationContext,
            locationContext,
          ),
      }),
  );

  /**
   * Handle scroll update when location changes
   */
  const prevLocation = usePrevious(location) ?? null;
  useEffect(() => {
    scrollBehavior.updateScroll(prevLocation, location);
  }, [location, prevLocation, scrollBehavior]);

  /**
   * Stop Scrollbehavior on unmount
   */
  useEffect(() => {
    return () => {
      scrollBehavior.stop();
    };
  }, [scrollBehavior]);

  /**
   * Provide the app with a way to register separately scrollable
   * elements to also be tracked by ScrollBehavior. (By default
   * ScrollBehavior only handles scrolling on the main document body.)
   */
  const contextValue = useMemo<ScrollBehaviorContextType>(
    () => ({
      registerElement: (key, element, shouldUpdateScroll) => {
        scrollBehavior.registerElement(
          key,
          element,
          shouldUpdateScroll,
          location,
        );
      },
      unregisterElement: (key) => {
        scrollBehavior.unregisterElement(key);
      },
      scrollBehavior,
    }),
    [location, scrollBehavior],
  );

  return (
    <ScrollBehaviorContext.Provider value={contextValue}>
      {React.Children.only(children)}
    </ScrollBehaviorContext.Provider>
  );
};
