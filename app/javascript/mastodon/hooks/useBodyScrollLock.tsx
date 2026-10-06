import { useId, useLayoutEffect } from 'react';

import {
  addToScrollLockStack,
  removeFromScrollLockStack,
} from '@/mastodon/reducers/slices/scrollLockStack';
import { isRedesignEnabled } from '@/mastodon/utils/environment';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from 'mastodon/store';

const getShouldLockBodyScroll = createAppSelector(
  [
    (state) => state.scrollLockStack.stack.length > 0,
    (state) => state.navigation.open,
    (state) => state.modal.get('stack').size > 0,
    (state) =>
      isRedesignEnabled() &&
      state.composer.displayState === 'showing' &&
      state.meta.get('layout') === 'mobile',
  ],
  (
    hasScrollLockStackItems: boolean,
    isMobileMenuOpen: boolean,
    isModalOpen: boolean,
    isRedesignComposerOpen: boolean,
  ) =>
    hasScrollLockStackItems ||
    isMobileMenuOpen ||
    isModalOpen ||
    isRedesignComposerOpen,
);

/**
 * This component locks scrolling on the body when
 * `getShouldLockBodyScroll` returns true.
 * Should only be used once per app.
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

/**
 * Utility hook for engaging the body scroll lock for a component
 * on mount & disabling it on unmount.
 */
export function useBodyScrollLock(active = true) {
  const dispatch = useAppDispatch();
  const id = useId();

  useLayoutEffect(() => {
    if (active) {
      dispatch(addToScrollLockStack(id));
    } else {
      dispatch(removeFromScrollLockStack(id));
    }

    return () => {
      dispatch(removeFromScrollLockStack(id));
    };
  }, [id, dispatch, active]);
}
