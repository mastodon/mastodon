import { useLayoutEffect, useEffect, useState } from 'react';

import { createAppSelector, useAppSelector } from 'mastodon/store';
import { getScrollbarWidth } from 'mastodon/utils/scrollbar';

const getShouldLockBodyScroll = createAppSelector(
  [
    (state) => state.navigation.open,
    (state) => state.modal.get('stack').size > 0,
  ],
  (isMobileMenuOpen: boolean, isModalOpen: boolean) => {
    return isMobileMenuOpen || isModalOpen;
  },
);

/**
 * This component locks scrolling on the `body` element when
 * `getShouldLockBodyScroll` returns true.
 *
 * The scrollbar width is taken into account and written to
 * a CSS custom property `--root-scrollbar-width`
 */

export const BodyScrollLock: React.FC = () => {
  const shouldLockBodyScroll = useAppSelector(getShouldLockBodyScroll);

  useLayoutEffect(() => {
    document.body.classList.toggle('with-modals--active', shouldLockBodyScroll);
  }, [shouldLockBodyScroll]);

  const [scrollbarWidth, setScrollbarWidth] = useState(() =>
    getScrollbarWidth(),
  );

  useEffect(() => {
    const handleResize = () => {
      setScrollbarWidth(getScrollbarWidth());
    };
    window.addEventListener('resize', handleResize, { passive: true });
    return () => {
      window.removeEventListener('resize', handleResize);
    };
  }, []);

  // Inject style element to make scrollbar width available
  // as CSS custom property
  useLayoutEffect(() => {
    const nonce = document
      .querySelector('meta[name=style-nonce]')
      ?.getAttribute('content');

    if (nonce) {
      const styleEl = document.createElement('style');
      styleEl.nonce = nonce;
      styleEl.innerHTML = `
        :root {
          --root-scrollbar-width: ${scrollbarWidth}px;
        }
      `;
      document.head.appendChild(styleEl);

      return () => {
        document.head.removeChild(styleEl);
      };
    }

    return () => '';
  }, [scrollbarWidth]);

  return null;
};
