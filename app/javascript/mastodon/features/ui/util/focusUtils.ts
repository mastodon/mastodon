import {
  getColumnSkipLinkId,
  getNavigationSkipLinkId,
} from '../components/skip_links';

/**
 * Out of a list of elements, return the first one whose top edge
 * is inside of the viewport, and return the element and its BoundingClientRect.
 */
function findFirstVisibleWithRect(
  items: HTMLElement[],
): { item: HTMLElement; rect: DOMRect } | null {
  const viewportHeight =
    window.innerHeight || document.documentElement.clientHeight;

  for (const item of items) {
    const rect = item.getBoundingClientRect();
    const isVisible = rect.top >= 0 && rect.top < viewportHeight;

    if (isVisible) {
      return { item, rect };
    }
  }

  return null;
}

function focusColumnTitle(index: number, multiColumn: boolean) {
  if (multiColumn) {
    const column = document.querySelector(`.column:nth-child(${index})`);
    if (column) {
      column
        .querySelector<HTMLAnchorElement>(
          `#${getColumnSkipLinkId(index - 1)}, #${getNavigationSkipLinkId()}`,
        )
        ?.focus();
    }
  } else {
    const idSelector =
      index === 2
        ? `#${getNavigationSkipLinkId()}`
        : `#${getColumnSkipLinkId(1)}`;

    document.querySelector<HTMLAnchorElement>(idSelector)?.focus();
  }
}

/**
 * Move focus to the column of the passed index (1-based).
 * Focus is placed on the topmost visible item, or the column title.
 */
export function focusColumn(index = 1) {
  // Skip the leftmost drawer in multi-column mode
  const isMultiColumnLayout = !!document.querySelector(
    'body.layout-multiple-columns',
  );
  const indexOffset = isMultiColumnLayout ? 1 : 0;

  const column = document.querySelector(
    `.column:nth-child(${index + indexOffset})`,
  );

  function fallback() {
    focusColumnTitle(index + indexOffset, isMultiColumnLayout);
  }

  if (!column) {
    fallback();
    return;
  }

  const container = column.querySelector('.scrollable');

  if (!container) {
    fallback();
    return;
  }

  const focusableItems = Array.from(
    container.querySelectorAll<HTMLElement>(
      '.focusable:not(.status__quote .focusable)',
    ),
  );

  // Find first item visible in the viewport
  const itemToFocus = findFirstVisibleWithRect(focusableItems);

  if (!itemToFocus) {
    fallback();
    return;
  }

  const viewportWidth =
    window.innerWidth || document.documentElement.clientWidth;
  const { item, rect } = itemToFocus;

  const scrollParent = isMultiColumnLayout
    ? container
    : document.documentElement;
  const columnHeaderHeight =
    parseInt(
      getComputedStyle(scrollParent).getPropertyValue('--column-header-height'),
    ) || 0;

  if (
    scrollParent.scrollTop > item.offsetTop - columnHeaderHeight ||
    rect.right > viewportWidth ||
    rect.left < 0
  ) {
    itemToFocus.item.scrollIntoView(true);
  }
  itemToFocus.item.focus();
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
 * Focus the topmost item of the column that currently has focus,
 * or the first column if none
 */
export function focusFirstItem() {
  const focusedElement = document.activeElement;
  const container =
    focusedElement?.closest('.scrollable') ??
    document.querySelector('.scrollable');

  if (!container) return;

  const itemToFocus = container.querySelector<HTMLElement>('.focusable');

  if (itemToFocus) {
    container.scrollTo(0, 0);
    itemToFocus.focus();
  }
}

/**
 * Focus the item next to the one with the provided index
 */
export function focusItemSibling(index: number, direction: 1 | -1) {
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
  let targetElement = siblingItem.matches('.focusable')
    ? siblingItem
    : siblingItem.querySelector<HTMLElement>('.focusable');

  // Otherwise, check if the item is a 'load more' button.
  if (!targetElement && siblingItem.matches('.load-more')) {
    targetElement = siblingItem;
  }

  if (targetElement) {
    targetElement.scrollIntoView({
      block: 'start',
    });

    targetElement.focus();
  }
}
