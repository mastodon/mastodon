import { isMobile } from '../is_mobile';

export const getScrollbarWidth = () => {
  if (isMobile(window.innerWidth)) {
    return 0;
  }
  const outer = document.createElement('div');
  outer.style.visibility = 'hidden';
  outer.style.overflow = 'scroll';
  document.body.appendChild(outer);

  const inner = document.createElement('div');
  outer.appendChild(inner);

  const scrollbarWidth = outer.offsetWidth - inner.offsetWidth;
  outer.remove();

  return scrollbarWidth;
};
