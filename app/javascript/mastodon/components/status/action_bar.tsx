import type React from 'react';
import { useCallback, useMemo } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import {
  muteAccount,
  unblockAccount,
  unmuteAccount,
} from '@/mastodon/actions/accounts';
import { initBlockModal } from '@/mastodon/actions/blocks';
import { directCompose, mentionCompose } from '@/mastodon/actions/compose';
import {
  initDomainBlockModal,
  unblockDomain,
} from '@/mastodon/actions/domain_blocks';
import { initAddFilter } from '@/mastodon/actions/filters';
import type { StatusInteractionIntent } from '@/mastodon/actions/interactions';
import { statusInteraction } from '@/mastodon/actions/interactions';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';
import { useRelationship } from '@/mastodon/hooks/useRelationship';
import { useStatus } from '@/mastodon/hooks/useStatus';
import { useIdentity } from '@/mastodon/identity_context';
import { quickBoosting } from '@/mastodon/initial_state';
import type { AccountShapeFull } from '@/mastodon/models/account';
import type { MenuItem } from '@/mastodon/models/dropdown_menu';
import type { Relationship } from '@/mastodon/models/relationship';
import type { StatusShape } from '@/mastodon/models/status';
import {
  PERMISSION_MANAGE_FEDERATION,
  PERMISSION_MANAGE_USERS,
} from '@/mastodon/permissions';
import { selectPlainAccount } from '@/mastodon/selectors/accounts';
import type { AppDispatch } from '@/mastodon/store';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import BookmarkIcon from '@/material-icons/400-24px/bookmark-fill.svg?react';
import BookmarkBorderIcon from '@/material-icons/400-24px/bookmark.svg?react';
import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';
import ReplyIcon from '@/material-icons/400-24px/reply.svg?react';
import ReplyAllIcon from '@/material-icons/400-24px/reply_all.svg?react';
import StarIcon from '@/material-icons/400-24px/star-fill.svg?react';
import StarBorderIcon from '@/material-icons/400-24px/star.svg?react';

import { Dropdown } from '../dropdown_menu';
import { IconButton } from '../icon_button';
import { RemoveQuoteHint } from '../status_action_bar/remove_quote_hint';

import { BoostButton } from './boost_button';
import type { MenuItemState } from './boost_button_utils';
import { quoteItemState, selectStatusState } from './boost_button_utils';
import type { StatusContextType } from './types';

interface StatusActionBarProps {
  statusId: string;
  contextType?: StatusContextType;
  withDismiss?: boolean;
  withCounters?: boolean;
  scrollKey?: string;
}

const messages = defineMessages({
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

export const StatusActionBar: React.FC<StatusActionBarProps> = ({
  statusId,
  contextType,
  withCounters,
  scrollKey,
}) => {
  const status = useStatus(statusId);
  const quotedAccountId = useAppSelector(
    (state) =>
      state.statuses.getIn([status?.quote?.quoted_status, 'account']) ?? null,
  );
  const currentAccountId = useCurrentAccountId();

  const dispatch = useAppDispatch();
  const handleReplyClick = useCallback(() => {
    dispatch(statusInteraction({ statusId, intent: 'reply' }));
  }, [dispatch, statusId]);
  const handleFavouriteClick = useCallback(() => {
    dispatch(statusInteraction({ statusId, intent: 'favourite' }));
  }, [dispatch, statusId]);
  const handleBookmarkClick = useCallback(() => {
    dispatch(statusInteraction({ statusId, intent: 'bookmark' }));
  }, [dispatch, statusId]);

  const intl = useIntl();

  if (!status) {
    return null;
  }

  const isReply =
    !status.in_reply_to_id || status.in_reply_to_account_id === status.account;
  const replyTitle = isReply
    ? intl.formatMessage(messages.reply)
    : intl.formatMessage(messages.replyAll);
  const replyIcon = isReply ? 'reply' : 'reply-all';
  const replyIconComponent = isReply ? ReplyIcon : ReplyAllIcon;

  const bookmarkTitle = intl.formatMessage(
    status.bookmarked ? messages.removeBookmark : messages.bookmark,
  );
  const favouriteTitle = intl.formatMessage(
    status.favourited ? messages.removeFavourite : messages.favourite,
  );

  const isQuotingMe = quotedAccountId === currentAccountId;
  const shouldShowQuoteRemovalHint =
    isQuotingMe && contextType === 'notifications';

  return (
    <div className='status__action-bar'>
      <div className='status__action-bar__button-wrapper'>
        <IconButton
          className='status__action-bar__button'
          title={replyTitle}
          icon={replyIcon}
          iconComponent={replyIconComponent}
          onClick={handleReplyClick}
          counter={status.replies_count}
        />
      </div>
      <div className='status__action-bar__button-wrapper'>
        <BoostButton statusId={statusId} counters={withCounters} />
      </div>
      <div className='status__action-bar__button-wrapper'>
        <IconButton
          className='status__action-bar__button star-icon'
          animate
          active={status.favourited}
          title={favouriteTitle}
          icon='star'
          iconComponent={status.favourited ? StarIcon : StarBorderIcon}
          onClick={handleFavouriteClick}
          counter={withCounters ? status.favourites_count : undefined}
        />
      </div>
      <div className='status__action-bar__button-wrapper'>
        <IconButton
          className='status__action-bar__button bookmark-icon'
          disabled={!currentAccountId}
          active={status.bookmarked}
          title={bookmarkTitle}
          icon='bookmark'
          iconComponent={status.bookmarked ? BookmarkIcon : BookmarkBorderIcon}
          onClick={handleBookmarkClick}
        />
      </div>
      <RemoveQuoteHint
        className='status__action-bar__button-wrapper'
        canShowHint={shouldShowQuoteRemovalHint}
      >
        {(dismissQuoteHint) => (
          <StatusActionMenu
            dismissQuoteHint={dismissQuoteHint}
            status={status}
            contextType={contextType}
            scrollKey={scrollKey}
          />
        )}
      </RemoveQuoteHint>
    </div>
  );
};

const StatusActionMenu: React.FC<{
  dismissQuoteHint: () => void;
  status: StatusShape;
  contextType?: StatusContextType;
  scrollKey?: string;
  withDismiss?: boolean;
}> = ({ status, dismissQuoteHint, contextType, scrollKey, withDismiss }) => {
  const account = useAppSelector((state) =>
    selectPlainAccount(state, status.account),
  );
  const { signedIn, accountId: currentAccountId, permissions } = useIdentity();
  const quotedAccountId = useAppSelector(
    (state) =>
      (state.statuses.getIn([status.quote?.quoted_status, 'account']) as
        | string
        | undefined) ?? null,
  );
  const relationship = useRelationship(account?.id);
  const statusQuoteState = useAppSelector((state) =>
    selectStatusState(state, status.id),
  );
  const quoteItem = quoteItemState(statusQuoteState);
  const intl = useIntl();
  const dispatch = useAppDispatch();

  const menu = useMemo(
    () =>
      getMenuItems({
        status,
        account,
        signedIn,
        contextType,
        currentAccountId,
        quotedAccountId,
        quoteItem,
        withDismiss,
        permissions,
        intl,
        relationship,
        dispatch,
      }),
    [
      account,
      currentAccountId,
      dispatch,
      contextType,
      intl,
      permissions,
      quoteItem,
      quotedAccountId,
      relationship,
      signedIn,
      status,
      withDismiss,
    ],
  );
  const handleOpen = useCallback(() => {
    dismissQuoteHint();
    return true;
  }, [dismissQuoteHint]);

  return (
    <Dropdown
      scrollKey={scrollKey}
      // status={status}
      needsStatusRefresh={quickBoosting && !status.quote_approval}
      items={menu}
      onOpen={handleOpen}
    >
      <IconButton
        className='status__action-bar__button'
        icon='ellipsis-h'
        iconComponent={MoreHorizIcon}
        title={intl.formatMessage(messages.more)}
      />
    </Dropdown>
  );
};

interface MenuItemsParams {
  status: StatusShape;
  account: AccountShapeFull | null;
  contextType?: StatusContextType;
  currentAccountId?: string;
  quotedAccountId: string | null;
  quoteItem: MenuItemState;
  withDismiss?: boolean;
  signedIn: boolean;
  permissions: number;
  intl: ReturnType<typeof useIntl>;
  relationship?: Relationship | null;
  dispatch: AppDispatch;
}

function getMenuItems({
  status,
  account,
  signedIn,
  contextType,
  currentAccountId,
  quotedAccountId,
  quoteItem,
  withDismiss,
  permissions,
  intl,
  relationship,
  dispatch,
}: MenuItemsParams) {
  const menu: MenuItem[] = [];

  const statusId = status.id;
  const statusUrl = status.url ?? status.uri;
  const publicStatus = ['public', 'unlisted'].includes(status.visibility);
  const pinnableStatus = ['public', 'unlisted', 'private'].includes(
    status.visibility,
  );
  const accountId = status.account;
  const mutingConversation = status.muted;
  const writtenByMe = accountId === currentAccountId;
  const isRemote = account && account.username !== account.acct;
  const isQuotingMe = quotedAccountId === currentAccountId;
  const domain = account?.acct.split('@')[1];

  menu.push({
    text: intl.formatMessage(messages.open),
    to: `/@${account?.acct}/${statusId}`,
  });

  if (publicStatus && isRemote) {
    menu.push({
      text: intl.formatMessage(messages.openOriginalPage),
      href: statusUrl,
    });
  }

  menu.push({
    text: intl.formatMessage(messages.copy),
    action: () => {
      void navigator.clipboard.writeText(statusUrl);
    },
  });

  if (publicStatus && 'share' in navigator) {
    menu.push({
      text: intl.formatMessage(messages.share),
      action: () => {
        void navigator.share({
          url: statusUrl,
        });
      },
    });
  }

  const statusInteractAction = (intent: StatusInteractionIntent) => {
    return () => {
      dispatch(statusInteraction({ statusId, contextType, intent }));
    };
  };

  if (publicStatus && !isRemote) {
    menu.push({
      text: intl.formatMessage(messages.embed),
      action: statusInteractAction('embed'),
    });
  }

  if (!signedIn) {
    return menu;
  }

  if (quickBoosting) {
    menu.push(null);
    menu.push({
      text: intl.formatMessage(quoteItem.title),
      description: quoteItem.meta
        ? intl.formatMessage(quoteItem.meta)
        : undefined,
      disabled: quoteItem.disabled,
      action: statusInteractAction('quote'),
    });
  }

  menu.push(null);

  if (writtenByMe && pinnableStatus) {
    menu.push({
      text: intl.formatMessage(status.pinned ? messages.unpin : messages.pin),
      action: statusInteractAction('pin'),
    });
    menu.push(null);
  }

  if (writtenByMe || withDismiss) {
    menu.push({
      text: intl.formatMessage(
        mutingConversation
          ? messages.unmuteConversation
          : messages.muteConversation,
      ),
      action: statusInteractAction('mute'),
    });
    if (writtenByMe && !['private', 'direct'].includes(status.visibility)) {
      menu.push({
        text: intl.formatMessage(messages.quotePolicyChange),
        action: statusInteractAction('edit_quote_policy'),
      });
    }
    menu.push(null);
  }

  if (writtenByMe) {
    menu.push({
      text: intl.formatMessage(messages.edit),
      action: statusInteractAction('edit'),
    });
    menu.push({
      text: intl.formatMessage(messages.delete),
      action: statusInteractAction('delete'),
      dangerous: true,
    });
    menu.push({
      text: intl.formatMessage(messages.redraft),
      action: statusInteractAction('redraft'),
      dangerous: true,
    });
  } else if (account) {
    menu.push({
      text: intl.formatMessage(messages.mention, {
        name: account.username,
      }),
      action: () => {
        // TODO: FIX ME
        dispatch(mentionCompose(account));
      },
    });
    menu.push({
      text: intl.formatMessage(messages.direct, {
        name: account.username,
      }),
      action: () => {
        // TODO: FIX ME
        dispatch(directCompose(account));
      },
    });
    menu.push(null);

    if (isQuotingMe) {
      menu.push({
        text: intl.formatMessage(messages.revokeQuote, {
          name: account.username,
        }),
        action: statusInteractAction('revoke_quote'),
        dangerous: true,
      });
    }

    const isMuted = !!relationship?.get('muting');
    menu.push({
      text: intl.formatMessage(isMuted ? messages.unmute : messages.mute, {
        name: account.username,
      }),
      action: () => {
        if (isMuted) {
          dispatch(unmuteAccount(accountId));
        } else {
          dispatch(muteAccount(accountId));
        }
      },
      dangerous: !isMuted,
    });

    const isBlocking = !!relationship?.blocking;
    menu.push({
      text: intl.formatMessage(isBlocking ? messages.unblock : messages.block, {
        name: account.username,
      }),
      action: () => {
        if (isBlocking) {
          dispatch(unblockAccount(accountId));
        } else {
          // TODO: FIX ME
          dispatch(initBlockModal(account));
        }
      },
      dangerous: !isBlocking,
    });

    menu.push(null);
    menu.push({
      text: intl.formatMessage(messages.filter),
      action: () => {
        dispatch(initAddFilter(status, { contextType }));
      },
      dangerous: true,
    });
    menu.push(null);

    menu.push({
      text: intl.formatMessage(messages.report, {
        name: account.username,
      }),
      action: statusInteractAction('report'),
      dangerous: true,
    });

    if (isRemote) {
      menu.push(null);

      const isDomainBlocking = !!relationship?.domain_blocking;
      menu.push({
        text: intl.formatMessage(
          isDomainBlocking ? messages.unblockDomain : messages.blockDomain,
          { domain },
        ),
        action: () => {
          if (isDomainBlocking) {
            dispatch(unblockDomain(domain));
          } else {
            // TODO: FIX ME
            dispatch(initDomainBlockModal(account));
          }
        },
        dangerous: !isDomainBlocking,
      });
    }

    if (
      (permissions & PERMISSION_MANAGE_USERS) === PERMISSION_MANAGE_USERS ||
      (isRemote &&
        (permissions & PERMISSION_MANAGE_FEDERATION) ===
          PERMISSION_MANAGE_FEDERATION)
    ) {
      menu.push(null);
      if ((permissions & PERMISSION_MANAGE_USERS) === PERMISSION_MANAGE_USERS) {
        menu.push({
          text: intl.formatMessage(messages.admin_account, {
            name: account.username,
          }),
          href: `/admin/accounts/${status.account}`,
        });
        menu.push({
          text: intl.formatMessage(messages.admin_status),
          href: `/admin/accounts/${status.account}/statuses/${status.id}`,
        });
      }
      if (
        isRemote &&
        (permissions & PERMISSION_MANAGE_FEDERATION) ===
          PERMISSION_MANAGE_FEDERATION
      ) {
        menu.push({
          text: intl.formatMessage(messages.admin_domain, {
            domain,
          }),
          href: `/admin/instances/${domain}`,
        });
      }
    }
  }
  return menu;
}
