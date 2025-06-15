import { useState, useEffect } from 'react';

const breakpoints = {
  openable: 759, // Device width at which the sidebar becomes an openable hamburger menu
  full: 1174, // Device width at which all 3 columns can be displayed
};

type Breakpoint = 'openable' | 'full';

export const useBreakpoint = (breakpoint: Breakpoint) => {
  const [isMatching, setIsMatching] = useState(false);

  useEffect(() => {
    const mediaWatcher = window.matchMedia(
      `(max-width: ${breakpoints[breakpoint]}px)`,
    );

    setIsMatching(mediaWatcher.matches);

    const handleChange = (e: MediaQueryListEvent) => {
      setIsMatching(e.matches);
    };

    mediaWatcher.addEventListener('change', handleChange);

    return () => {
      mediaWatcher.removeEventListener('change', handleChange);
    };
  }, [breakpoint, setIsMatching]);

  return isMatching;
};

interface WithBreakpointType {
  matchesBreakpoint: boolean;
}

export function withBreakpoint<P>(
  Component: React.ComponentType<P & WithBreakpointType>,
  breakpoint: Breakpoint = 'full',
) {
  const displayName = `withMobileLayout(${Component.displayName ?? Component.name})`;

  const ComponentWithBreakpoint = (props: P) => {
    const matchesBreakpoint = useBreakpoint(breakpoint);

    return <Component matchesBreakpoint={matchesBreakpoint} {...props} />;
  };

  ComponentWithBreakpoint.displayName = displayName;

  return ComponentWithBreakpoint;
}
