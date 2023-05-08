/** @type {number | null} */
let cachedScrollbarWidth = null;

/**
 * @returns {number}
 */
const getActualScrollbarWidth = () => {
  const outer = document.createElement('div');
  outer.style.visibility = 'hidden';
  outer.style.overflow = 'scroll';
  document.body.appendChild(outer);

  const inner = document.createElement('div');
  outer.appendChild(inner);

  const scrollbarWidth = outer.offsetWidth - inner.offsetWidth;
  outer.parentNode.removeChild(outer);

  return scrollbarWidth;
};

/**
 * @returns {number}
 */
export const getScrollbarWidth = () => {
  if (cachedScrollbarWidth !== null) {
    return cachedScrollbarWidth;
  }

  const scrollbarWidth = getActualScrollbarWidth();
  cachedScrollbarWidth = scrollbarWidth;

  return scrollbarWidth;
};
