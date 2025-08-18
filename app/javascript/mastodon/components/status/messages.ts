import { defineMessages } from 'react-intl';

export const messages = defineMessages({
  delete: { id: 'status.delete', defaultMessage: 'Delete' },
  redraft: { id: 'status.redraft', defaultMessage: 'Delete & re-draft' },
  edit: { id: 'status.edit', defaultMessage: 'Edit' },
  direct: { id: 'status.direct', defaultMessage: 'Privately mention @{name}' },
  mention: { id: 'status.mention', defaultMessage: 'Mention @{name}' },
  mute: { id: 'account.mute', defaultMessage: 'Mute @{name}' },
  block: { id: 'account.block', defaultMessage: 'Block @{name}' },
  reply: { id: 'status.reply', defaultMessage: 'Reply' },
  share: { id: 'status.share', defaultMessage: 'Share' },
  more: { id: 'status.more', defaultMessage: 'More' },
  replyAll: { id: 'status.replyAll', defaultMessage: 'Reply to thread' },
  reblog: { id: 'status.reblog', defaultMessage: 'Boost' },
  reblog_private: {
    id: 'status.reblog_private',
    defaultMessage: 'Boost with original visibility',
  },
  cancel_reblog_private: {
    id: 'status.cancel_reblog_private',
    defaultMessage: 'Unboost',
  },
  cannot_reblog: {
    id: 'status.cannot_reblog',
    defaultMessage: 'This post cannot be boosted',
  },
  favourite: { id: 'status.favourite', defaultMessage: 'Favorite' },
  removeFavourite: {
    id: 'status.remove_favourite',
    defaultMessage: 'Remove from favorites',
  },
  bookmark: { id: 'status.bookmark', defaultMessage: 'Bookmark' },
  removeBookmark: {
    id: 'status.remove_bookmark',
    defaultMessage: 'Remove bookmark',
  },
  open: { id: 'status.open', defaultMessage: 'Expand this status' },
  report: { id: 'status.report', defaultMessage: 'Report @{name}' },
  muteConversation: {
    id: 'status.mute_conversation',
    defaultMessage: 'Mute conversation',
  },
  unmuteConversation: {
    id: 'status.unmute_conversation',
    defaultMessage: 'Unmute conversation',
  },
  pin: { id: 'status.pin', defaultMessage: 'Pin on profile' },
  unpin: { id: 'status.unpin', defaultMessage: 'Unpin from profile' },
  embed: { id: 'status.embed', defaultMessage: 'Get embed code' },
  admin_account: {
    id: 'status.admin_account',
    defaultMessage: 'Open moderation interface for @{name}',
  },
  admin_status: {
    id: 'status.admin_status',
    defaultMessage: 'Open this post in the moderation interface',
  },
  admin_domain: {
    id: 'status.admin_domain',
    defaultMessage: 'Open moderation interface for {domain}',
  },
  copy: { id: 'status.copy', defaultMessage: 'Copy link to post' },
  blockDomain: {
    id: 'account.block_domain',
    defaultMessage: 'Block domain {domain}',
  },
  unblockDomain: {
    id: 'account.unblock_domain',
    defaultMessage: 'Unblock domain {domain}',
  },
  unmute: { id: 'account.unmute', defaultMessage: 'Unmute @{name}' },
  unblock: { id: 'account.unblock', defaultMessage: 'Unblock @{name}' },
  filter: { id: 'status.filter', defaultMessage: 'Filter this post' },
  openOriginalPage: {
    id: 'account.open_original_page',
    defaultMessage: 'Open original page',
  },
  revokeQuote: {
    id: 'status.revoke_quote',
    defaultMessage: 'Remove my post from @{name}’s post',
  },
  quotePolicyChange: {
    id: 'status.quote_policy_change',
    defaultMessage: 'Change who can quote',
  },
});
