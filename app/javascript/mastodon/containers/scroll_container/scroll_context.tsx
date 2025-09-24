import React, { useEffect, useMemo, useRef, useState } from 'react';

import { useLocation, useHistory } from 'react-router-dom';

import type { LocationBase } from 'scroll-behavior';
import ScrollBehavior from 'scroll-behavior';

import type { MastodonLocationState } from 'mastodon/components/router';
import { usePrevious } from 'mastodon/hooks/usePrevious';

import { defaultShouldUpdateScroll } from './default_should_update_scroll';
import type {
  ShouldUpdateScrollFn,
  LocationContext,
} from './default_should_update_scroll';
import { SessionStorage } from './state_storage';

type ScrollBehaviorInstance = InstanceType<
  typeof ScrollBehavior<LocationBase, LocationContext>
>;

export interface ScrollBehaviorContextType {
  registerElement: (
    key: string,
    element: HTMLElement,
    shouldUpdateScroll: (
      prevLocationContext: LocationContext | null,
      locationContext: LocationContext,
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
 * This component is a port of the unmaintained https://github.com/ytase/react-router-scroll/
 */

export const ScrollContext: React.FC<ScrollContextProps> = ({
  children,
  shouldUpdateScroll = defaultShouldUpdateScroll,
}) => {
  const location = useLocation<MastodonLocationState>();
  const history = useHistory<MastodonLocationState>();

  const currentLocationRef = useRef(location);
  useEffect(() => {
    currentLocationRef.current = location;
  }, [location]);

  const [scrollBehavior] = useState(
    (): ScrollBehaviorInstance =>
      new ScrollBehavior({
        // eslint-disable-next-line @typescript-eslint/unbound-method
        addNavigationListener: history.listen,
        stateStorage: new SessionStorage(),
        getCurrentLocation: () =>
          currentLocationRef.current as unknown as LocationBase,
        shouldUpdateScroll: (
          prevLocationContext: LocationContext | null,
          locationContext: LocationContext,
        ) =>
          // Hack to allow accessing scrollBehavior._stateStorage
          shouldUpdateScroll.call(
            scrollBehavior,
            prevLocationContext,
            locationContext,
          ),
      }),
  );

  // Handle scroll update when location changes
  const prevLocation = usePrevious(location) ?? null;
  useEffect(() => {
    scrollBehavior.updateScroll(prevLocation, location);
  }, [location, prevLocation, scrollBehavior]);

  useEffect(() => {
    return () => {
      scrollBehavior.stop();
    };
  }, [scrollBehavior]);

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
