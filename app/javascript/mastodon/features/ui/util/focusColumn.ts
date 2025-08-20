import initialState from '@/mastodon/initial_state';

interface Options {
  index?: number;
  focusItem?: 'first' | 'first-visible';
}

/**
 * Move focus to the column of the passed index (1-based).
 * Can either focus the topmost item or the first one in the viewport
 */
export function focusColumn({ index = 1, focusItem = 'first' }: Options = {}) {
  // Skip the leftmost drawer in multi-column mode
  const indexOffset = initialState?.meta.advanced_layout ? 1 : 0;

  const column = document.querySelector(
    `.column:nth-child(${index + indexOffset})`,
  );

  if (!column) return;

  const container = column.querySelector('.scrollable');

  if (!container) return;

  let itemToFocus: HTMLElement | null = null;

  if (focusItem === 'first-visible') {
    const focusableItems = Array.from(
      container.querySelectorAll<HTMLElement>('.focusable'),
    );

    const viewportHeight =
      window.innerHeight || document.documentElement.clientHeight;

    // Find first item visible in the viewport
    itemToFocus =
      focusableItems.find((item) => {
        const { top } = item.getBoundingClientRect();
        return top >= 0 && top < viewportHeight;
      }) ?? null;
  } else {
    itemToFocus = container.querySelector('.focusable');
  }

  if (itemToFocus) {
    if (container.scrollTop > itemToFocus.offsetTop) {
      itemToFocus.scrollIntoView(true);
    }
    itemToFocus.focus();
  }
}
