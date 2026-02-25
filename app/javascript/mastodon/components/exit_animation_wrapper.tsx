import { useEffect, useState } from 'react';

/**
 * A helper component for managing the rendering of components that
 * need to stay in the DOM a bit longer to finish their CSS exit animation.
 *
 * In the future, replace this component with plain CSS once that is feasible.
 * This will require broader support for `transition-behavior: allow-discrete`
 * and https://developer.mozilla.org/en-US/docs/Web/CSS/overlay.
 */
export const ExitAnimationWrapper: React.FC<{
  /**
   * Set this to true to indicate that the nested component should be rendered
   */
  isActive: boolean;
  /**
   * How long the component should be rendered after `isActive` was set to `false`
   */
  delayMs?: number;
  /**
   * Set this to true to also delay the entry of the nested component until after
   * another one has exited full.
   */
  withEntryDelay?: boolean;
  /**
   * Render prop that provides the nested component with the `delayedIsActive` flag
   */
  children: (delayedIsActive: boolean) => React.ReactNode;
}> = ({ isActive, delayMs = 500, withEntryDelay, children }) => {
  const [delayedIsActive, setDelayedIsActive] = useState(
    isActive && !withEntryDelay,
  );

  useEffect(() => {
    const withDelay = !isActive || withEntryDelay;

    const timeout = setTimeout(
      () => {
        setDelayedIsActive(isActive);
      },
      withDelay ? delayMs : 0,
    );

    return () => {
      clearTimeout(timeout);
    };
  }, [isActive, delayMs, withEntryDelay]);

  if (!isActive && !delayedIsActive) {
    return null;
  }

  return children(isActive && delayedIsActive);
};
