import {
  ArrowsClockwiseIcon,
  BookmarkSimpleIcon,
  ChatCircleIcon,
  HeartIcon,
  QuotesIcon,
} from '@phosphor-icons/react';

import { isRedesignEnabled } from '@/mastodon/utils/environment';
import BookmarkLegacyIcon from '@/material-icons/400-24px/bookmark-fill.svg?react';
import BookmarkBorderLegacyIcon from '@/material-icons/400-24px/bookmark.svg?react';
import QuoteLegacyIcon from '@/material-icons/400-24px/format_quote-fill.svg?react';
import BoostLegacyIcon from '@/material-icons/400-24px/repeat.svg?react';
import ReplyLegacyIcon from '@/material-icons/400-24px/reply.svg?react';
import ReplyAllLegacyIcon from '@/material-icons/400-24px/reply_all.svg?react';
import StarLegacyIcon from '@/material-icons/400-24px/star-fill.svg?react';
import StarBorderLegacyIcon from '@/material-icons/400-24px/star.svg?react';
import BoostActiveIcon from '@/svg-icons/boost_active.svg?react';
import BoostActiveLegacyIcon from '@/svg-icons/repeat_active.svg?react';

import { iconWeight } from '../icon';

export const StatusReplyIcon = isRedesignEnabled()
  ? ChatCircleIcon
  : ReplyLegacyIcon;
export const StatusReplyAllIcon = isRedesignEnabled()
  ? StatusReplyIcon
  : ReplyAllLegacyIcon;
export const StatusQuoteIcon = isRedesignEnabled()
  ? QuoteLegacyIcon
  : QuotesIcon;
export const StatusBoostIcon = isRedesignEnabled()
  ? ArrowsClockwiseIcon
  : BoostLegacyIcon;
export const StatusBoostActiveIcon = isRedesignEnabled()
  ? BoostActiveIcon
  : BoostActiveLegacyIcon;
export const StatusLikeIcon = isRedesignEnabled()
  ? HeartIcon
  : StarBorderLegacyIcon;
export const StatusLikeActiveIcon = isRedesignEnabled()
  ? iconWeight(HeartIcon, 'fill')
  : StarLegacyIcon;
export const StatusBookmarkIcon = isRedesignEnabled()
  ? BookmarkSimpleIcon
  : BookmarkBorderLegacyIcon;
export const StatusBookmarkActiveIcon = isRedesignEnabled()
  ? iconWeight(BookmarkSimpleIcon, 'fill')
  : BookmarkLegacyIcon;
