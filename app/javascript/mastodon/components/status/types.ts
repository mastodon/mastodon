import type { ComponentClass, MouseEventHandler, ReactNode } from 'react';

import type { Account } from '@/mastodon/models/account';

import type { StatusHeaderRenderFn } from './header';

// Taken from the Status component.
export interface StatusProps {
  account?: Account;
  children?: ReactNode;
  previousId?: string;
  rootId?: string;
  onClick?: MouseEventHandler<HTMLDivElement>;
  muted?: boolean;
  hidden?: boolean;
  unread?: boolean;
  featured?: boolean;
  showThread?: boolean;
  showActions?: boolean;
  isQuotedPost?: boolean;
  shouldHighlightOnMount?: boolean;
  getScrollPosition?: () => null | { height: number; top: number };
  updateScrollBottom?: (snapshot: number) => void;
  cacheMediaWidth?: (width: number) => void;
  cachedMediaWidth?: number;
  scrollKey?: string;
  skipPrepend?: boolean;
  avatarSize?: number;
  unfocusable?: boolean;
  headerRenderFn?: StatusHeaderRenderFn;
  contextType?: string;
}

export type StatusComponent = ComponentClass<
  StatusProps,
  { showMedia?: boolean; showDespiteFilter?: boolean }
>;
