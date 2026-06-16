import type { ComponentClass, MouseEventHandler, ReactNode } from 'react';

import type { Account } from '@/mastodon/models/account';
import type { Status } from '@/mastodon/models/status';

import type { StatusHeaderRenderFn } from './header';

// Taken from the Status component.
export interface StatusProps {
  status: Status;
  account: Account;
  children?: ReactNode;
  previousId?: string;
  nextInReplyToId?: string;
  rootId?: string;
  onClick?: MouseEventHandler<HTMLDivElement>;
  onReply: (status: Status) => void;
  onFavourite: (status: Status) => void;
  onReblog: (status: Status, event?: unknown) => void;
  onQuote: (status: Status) => void;
  onDelete?: (status: Status) => void;
  onDirect?: (status: Status) => void;
  onMention: (account: Account) => void;
  onPin?: (status: Status) => void;
  onOpenMedia: (
    statusId: string,
    media: unknown,
    index: number,
    lang?: string,
  ) => void;
  onOpenVideo: (
    statusId: string,
    media: unknown,
    lang?: string,
    options?: unknown,
  ) => void;
  onBlock?: (status: Status) => void;
  onAddFilter?: (status: Status) => void;
  onEmbed?: (status: Status) => void;
  onHeightChange?: () => void;
  onToggleHidden: (status: Status) => void;
  onToggleCollapsed: (status: Status, isCollapsed: boolean) => void;
  onTranslate: (status: Status) => void;
  onInteractionModal?: (type: string, status: Status) => void;
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
  deployPictureInPicture: (
    status: Status,
    type: string,
    mediaProps: unknown,
  ) => void;
  unfocusable?: boolean;
  headerRenderFn?: StatusHeaderRenderFn;
  pictureInPicture: Immutable.Map<'inUse' | 'available', boolean>;
  contextType?: string;
  history?: {
    location: { pathname: string };
    push: (path: string, state?: unknown) => void;
    replace: (path: string, state?: unknown) => void;
  };
}

export type StatusComponent = ComponentClass<
  StatusProps,
  { showMedia?: boolean; showDespiteFilter?: boolean }
>;
