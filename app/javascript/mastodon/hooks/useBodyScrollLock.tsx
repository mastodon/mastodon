import { useId, useLayoutEffect } from 'react';

import {
  addCustomModal,
  removeCustomModal,
} from '@/mastodon/reducers/slices/customModals';
import { isRedesignEnabled } from '@/mastodon/utils/environment';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from 'mastodon/store';

const getShouldLockBodyScroll = createAppSelector(
  [
    (state) => state.navigation.open,
    (state) => state.modal.get('stack').size > 0,
    (state) => state.customModals.stack.length > 0,
    (state) =>
      isRedesignEnabled() &&
      state.composer.displayState === 'showing' &&
      state.meta.get('layout') === 'mobile',
  ],
  (
    isMobileMenuOpen: boolean,
    isModalOpen: boolean,
    isCustomModalOpen: boolean,
    isRedesignComposerOpen: boolean,
  ) =>
    isMobileMenuOpen ||
    isModalOpen ||
    isCustomModalOpen ||
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
export function useBodyScrollLock(modalId?: string) {
  const dispatch = useAppDispatch();
  const uniqueId = useId();
  const id = modalId ?? uniqueId;

  useLayoutEffect(() => {
    dispatch(addCustomModal(id));

    return () => {
      dispatch(removeCustomModal(id));
    };
  }, [id, dispatch]);
}
