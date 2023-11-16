import { isMobile } from '../is_mobile';

let cachedScrollbarWidth: number | null = null;

const getActualScrollbarWidth = () => {
  const outer = document.createElement('div');
  outer.style.visibility = 'hidden';
  outer.style.overflow = 'scroll';
  document.body.appendChild(outer);

  const inner = document.createElement('div');
  outer.appendChild(inner);

  const scrollbarWidth = outer.offsetWidth - inner.offsetWidth;
  // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
  outer.parentNode!.removeChild(outer);

  return scrollbarWidth;
};

export const getScrollbarWidth = () => {
  if (cachedScrollbarWidth !== null) {
    return cachedScrollbarWidth;
  }

  const scrollbarWidth = isMobile(window.innerWidth)
    ? 0
    : getActualScrollbarWidth();
  cachedScrollbarWidth = scrollbarWidth;

  return scrollbarWidth;
};
