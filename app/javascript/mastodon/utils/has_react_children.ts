import { Children } from 'react';
import type { ReactNode } from 'react';

export function hasReactChildren(children: ReactNode): boolean {
  if (!children) {
    return false;
  }

  const childrenCount = Children.toArray(children).filter(Boolean).length;

  return childrenCount > 0;
}
