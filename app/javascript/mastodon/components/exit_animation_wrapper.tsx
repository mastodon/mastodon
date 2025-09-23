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
   * Render prop that provides the nested component with an `isVisible` flag
   * which is based on `isActive`, but delayed, to allow for an exit animation
   */
  children: (isVisible: boolean) => React.ReactNode;
}> = ({ isActive = false, delayMs = 500, withEntryDelay, children }) => {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    if (isActive && !withEntryDelay) {
      setIsVisible(true);

      return () => '';
    } else {
      const timeout = setTimeout(() => {
        setIsVisible(isActive);
      }, delayMs);

      return () => {
        clearTimeout(timeout);
      };
    }
  }, [isActive, delayMs, withEntryDelay]);

  if (!isActive && !isVisible) {
    return null;
  }

  return children(isActive && isVisible);
};
