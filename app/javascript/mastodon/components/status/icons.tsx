import {
  ArrowsClockwiseIcon,
  BookmarkSimpleIcon,
  ChatCircleIcon,
  HeartIcon,
  QuotesIcon,
} from '@phosphor-icons/react';

import BoostActiveIcon from '@/svg-icons/boost_active.svg?react';

import { iconWeight } from '../icon';

export const StatusReplyIcon = ChatCircleIcon;
export const StatusReplyAllIcon = StatusReplyIcon;
export const StatusQuoteIcon = QuotesIcon;
export const StatusBoostIcon = ArrowsClockwiseIcon;
export const StatusBoostActiveIcon = BoostActiveIcon;
export const StatusLikeIcon = HeartIcon;
export const StatusLikeActiveIcon = iconWeight(HeartIcon, 'fill');
export const StatusBookmarkIcon = BookmarkSimpleIcon;
export const StatusBookmarkActiveIcon = iconWeight(BookmarkSimpleIcon, 'fill');
