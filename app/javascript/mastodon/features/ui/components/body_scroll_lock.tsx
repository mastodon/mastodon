import { useLayoutEffect } from 'react';

import { createAppSelector, useAppSelector } from 'mastodon/store';

const getShouldLockBodyScroll = createAppSelector(
  [
    (state) => state.navigation.open,
    (state) => state.modal.get('stack').size > 0,
  ],
  (isMobileMenuOpen: boolean, isModalOpen: boolean) =>
    isMobileMenuOpen || isModalOpen,
);

/**
 * This component locks scrolling on the body when
 * `getShouldLockBodyScroll` returns true.
 */

export const BodyScrollLock: React.FC = () => {
  const shouldLockBodyScroll = useAppSelector(getShouldLockBodyScroll);

  useLayoutEffect(() => {
    document.documentElement.classList.toggle(
      'has-modal',
      shouldLockBodyScroll,
    );
  }, [shouldLockBodyScroll]);

  return null;
};
