import type { ComponentType, MouseEventHandler, ReactNode } from 'react';

import type { Account as TAccount } from '@/mastodon/models/account';
import type { Status as TStatus } from '@/mastodon/models/status';

import Status from '../status';

import type { StatusHeaderRenderFn } from './header';

// Taken from the Status component.
export interface StatusProps {
  status: TStatus;
  account?: TAccount;
  children?: ReactNode;
  previousId?: string;
  nextInReplyToId?: string;
  rootId?: string;
  onClick?: MouseEventHandler<HTMLDivElement>;
  onReply: (status: TStatus) => void;
  onFavourite: (status: TStatus) => void;
  onReblog: (status: TStatus, event?: unknown) => void;
  onQuote: (status: TStatus) => void;
  onDelete?: (status: TStatus) => void;
  onDirect?: (status: TStatus) => void;
  onMention: (account: TAccount) => void;
  onPin?: (status: TStatus) => void;
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
  onBlock?: (status: TStatus) => void;
  onAddFilter?: (status: TStatus) => void;
  onEmbed?: (status: TStatus) => void;
  onHeightChange?: () => void;
  onToggleHidden: (status: TStatus) => void;
  onToggleCollapsed: (status: TStatus, isCollapsed: boolean) => void;
  onTranslate: (status: TStatus) => void;
  onInteractionModal?: (type: string, status: TStatus) => void;
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
    status: TStatus,
    type: string,
    mediaProps: unknown,
  ) => void;
  unfocusable?: boolean;
  headerRenderFn?: StatusHeaderRenderFn;
  pictureInPicture: Immutable.Map<'inUse' | 'available', boolean>;
  contextType?: string;
  withCounters?: boolean;
}

export const TypedStatus = Status as ComponentType<StatusProps>;
