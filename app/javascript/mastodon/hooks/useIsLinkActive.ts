import { matchPath, useLocation } from 'react-router';
import type { NavLinkProps } from 'react-router-dom';

export function useIsLinkActive(to?: NavLinkProps['to']) {
  const location = useLocation();

  if (!to) {
    return false;
  }

  const linkTarget = typeof to === 'function' ? to(location) : to;

  return !!matchPath(location.pathname, {
    path: typeof linkTarget === 'string' ? linkTarget : linkTarget.pathname,
  });
}
