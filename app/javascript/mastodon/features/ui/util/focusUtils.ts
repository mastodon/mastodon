import { initialState } from '@/mastodon/initial_state';

interface FocusColumnOptions {
  index?: number;
  focusItem?: 'first' | 'first-visible';
}

/**
 * Move focus to the column of the passed index (1-based).
 * Can either focus the topmost item or the first one in the viewport
 */
export function focusColumn({
  index = 1,
  focusItem = 'first',
}: FocusColumnOptions = {}) {
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
      container.querySelectorAll<HTMLElement>(
        '.focusable:not(.status__quote .focusable)',
      ),
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

/**
 * Get the index of the currently focused item in one of our item lists
 */
export function getFocusedItemIndex() {
  const focusedItem = document.activeElement?.closest('.item-list > *');
  if (!focusedItem) return -1;

  const { parentElement } = focusedItem;
  if (!parentElement) return -1;

  const items = Array.from(parentElement.children);
  return items.indexOf(focusedItem);
}

/**
 * Focus the item next to the one with the provided index
 */
export function focusItemSibling(
  index: number,
  direction: 1 | -1,
  scrollThreshold = 62,
) {
  const focusedElement = document.activeElement;
  const itemList = focusedElement?.closest('.item-list');

  const siblingItem = itemList?.querySelector<HTMLElement>(
    // :nth-child uses 1-based indexing
    `.item-list > :nth-child(${index + 1 + direction})`,
  );

  if (!siblingItem) {
    return;
  }

  // If sibling element is empty, we skip it
  if (siblingItem.matches(':empty')) {
    focusItemSibling(index + direction, direction);
    return;
  }

  // Check if the sibling is a post or a 'follow suggestions' widget
  let targetElement = siblingItem.querySelector<HTMLElement>('.focusable');

  // Otherwise, check if the item is a 'load more' button.
  if (!targetElement && siblingItem.matches('.load-more')) {
    targetElement = siblingItem;
  }

  if (targetElement) {
    const elementRect = targetElement.getBoundingClientRect();

    const isFullyVisible =
      elementRect.top >= scrollThreshold &&
      elementRect.bottom <= window.innerHeight;

    if (!isFullyVisible) {
      targetElement.scrollIntoView({
        block: direction === 1 ? 'start' : 'center',
      });
    }

    targetElement.focus();
  }
}
