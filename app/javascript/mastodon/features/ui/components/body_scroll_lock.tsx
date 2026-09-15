import { useLayoutEffect } from 'react';

import { isRedesignEnabled } from '@/mastodon/utils/environment';
import { createAppSelector, useAppSelector } from 'mastodon/store';

const getShouldLockBodyScroll = createAppSelector(
  [
    (state) => state.navigation.open,
    (state) => state.modal.get('stack').size > 0,
    (state) =>
      isRedesignEnabled() &&
      state.composer.displayState === 'showing' &&
      state.meta.get('layout') === 'mobile',
  ],
  (
    isMobileMenuOpen: boolean,
    isModalOpen: boolean,
    isRedesignComposerOpen: boolean,
  ) => isMobileMenuOpen || isModalOpen || isRedesignComposerOpen,
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
