import {
  createContext,
  useContext,
  useRef,
  useLayoutEffect,
  useCallback,
} from 'react';

import { useLocation } from 'react-router-dom';

import { polymorphicForwardRef } from '@/types/polymorphic';

import type { MastodonLocation } from '../router';

export const FOCUS_TARGET = {
  POST: 'detailed-status',
} as const;

export type FocusTarget =
  | boolean
  | (typeof FOCUS_TARGET)[keyof typeof FOCUS_TARGET];

const FocusTargetContext =
  createContext<React.MutableRefObject<FocusTarget> | null>(null);

/**
 * `FocusTargetProvider` keeps track of whether focus should be
 * set after a navigation. By default, any navigation will set the
 * current value of `focusTargetRef` to `true`, which will cause
 * the `NavigationFocusTarget` component to focus itself when it mounts.
 *
 * To disable this behaviour for a navigation, the focus target can be
 * set to `false` using location state, for example:
 * ```
 * location.push(url, { focusTarget: false });
 * ```
 *
 * If the target page contains multiple `NavigationFocusTarget` components
 * (e.g. a main heading and a post that should be focused), give the more
 * specific `NavigationFocusTarget` instance a name, and pass the same name
 * via location state:
 * ```
 * location.push(url, { focusTarget: 'detailed-status' });
 * ```
 */

export const FocusTargetProvider: React.FC<{
  children: React.ReactNode;
}> = ({ children }) => {
  const focusTargetRef = useRef<FocusTarget>(false);
  const previousLocationRef = useRef<
    | (Pick<MastodonLocation, 'pathname' | 'search'> & {
        focusTarget?: FocusTarget;
      })
    | null
  >(null);

  const { pathname, search, state } = useLocation<{
    focusTarget?: FocusTarget;
  } | null>();

  const { focusTarget } = state ?? {};

  useLayoutEffect(() => {
    // We never want to set focus on page load, so we keep
    // track of whether a manual navigation has occurred by comparing
    // our current with the previous location:
    const previous = previousLocationRef.current;

    // Bail out on the first render, populate previousLocationRef
    if (previous === null) {
      previousLocationRef.current = { pathname, search, focusTarget };
      return;
    }

    // Bail out if location hasn't changed
    if (
      previous.pathname === pathname &&
      previous.search === search &&
      previous.focusTarget === focusTarget
    ) {
      return;
    }

    // Location has changed:
    // - Set focusTarget
    // – Store current location as previous
    // (We store `focusTarget` as `false` to allow overriding it.)
    previousLocationRef.current = { pathname, search, focusTarget: false };
    focusTargetRef.current = focusTarget ?? true;
  }, [pathname, search, focusTarget]);

  return (
    <FocusTargetContext.Provider value={focusTargetRef}>
      {children}
    </FocusTargetContext.Provider>
  );
};

export function useFocusOnNavigation(targetName?: string) {
  const focusTargetRef = useContext(FocusTargetContext);

  return useCallback(
    (element: HTMLElement | null) => {
      const focusTarget = focusTargetRef?.current;

      // Bail out if focusTarget was set to `false`
      if (!element || !focusTarget) {
        return;
      }

      if (focusTarget === true || focusTarget === targetName) {
        setTimeout(() => {
          element.focus({ preventScroll: true });
        }, 0);
      }
    },
    [focusTargetRef, targetName],
  );
}

interface FocusTargetElementProps extends React.ComponentPropsWithoutRef<'h1'> {
  focusTargetName?: string;
}

export const NavigationFocusTarget = polymorphicForwardRef<
  'h1',
  FocusTargetElementProps
>(({ as: Component = 'h1', focusTargetName, children, ...otherProps }) => {
  const focusOnNavigation = useFocusOnNavigation(focusTargetName);

  return (
    <Component ref={focusOnNavigation} tabIndex={-1} {...otherProps}>
      {children}
    </Component>
  );
});
