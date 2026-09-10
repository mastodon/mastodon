import type React from 'react';
import { useCallback, useMemo } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import {
  ArrowsClockwiseIcon,
  BookmarkSimpleIcon,
  ChatCircleTextIcon,
  DotsThreeIcon,
  HeartIcon,
  QuotesIcon,
  ShareFatIcon,
} from '@phosphor-icons/react';

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
import type { StatusInteractionIntent } from '@/mastodon/actions/interactions';
import { statusInteraction } from '@/mastodon/actions/interactions';
import { fetchStatus } from '@/mastodon/actions/statuses';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';
import { useRelationship } from '@/mastodon/hooks/useRelationship';
import { useStatus } from '@/mastodon/hooks/useStatus';
import { useIdentity } from '@/mastodon/identity_context';
import { quickBoosting } from '@/mastodon/initial_state';
import type { Account } from '@/mastodon/models/account';
import type { MenuItem as DropdownItem } from '@/mastodon/models/dropdown_menu';
import type { Relationship } from '@/mastodon/models/relationship';
import type { StatusShape } from '@/mastodon/models/status';
import {
  PERMISSION_MANAGE_FEDERATION,
  PERMISSION_MANAGE_USERS,
} from '@/mastodon/permissions';
import type {
  StatusConditions,
  StatusInteractionsAllowed,
} from '@/mastodon/selectors/statuses';
import {
  selectStatusConditions,
  selectStatusInteractionsAllowed,
} from '@/mastodon/selectors/statuses';
import type { AppDispatch } from '@/mastodon/store';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import { isRedesignEnabled } from '@/mastodon/utils/environment';

import {
  Button,
  IconButton,
  ToggleButton,
  ToggleIconButton,
} from '../button/redesign';
import { iconWeight, useIconWeight } from '../icon';
import {
  Menu,
  MenuItem,
  MenuItemDivider,
  MenuItemLink,
  MenuList,
  MenuTrigger,
} from '../menu';
import { RemoveQuoteHint } from '../status_action_bar/remove_quote_hint';

import { boostItemState, quoteItemState } from './boost_button_utils';
import { useStatusContext } from './hooks';
import classes from './styles.module.scss';

interface StatusActionBarProps {
  statusId: string;
  withDismiss?: boolean;
  withCounters?: boolean;
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
  replyAll: { id: 'status.replyAll', defaultMessage: 'Reply to thread' },
  favourite: { id: 'status.favourite', defaultMessage: 'Favorite' },
  removeFavourite: {
    id: 'status.remove_favourite',
    defaultMessage: 'Remove from favorites',
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
  withDismiss,
  withCounters,
}) => {
  const status = useStatus(statusId);
  const quotedAccountId = useAppSelector(
    (state) =>
      state.statuses.getIn([status?.quote?.quoted_status, 'account']) ?? null,
  );
  const currentAccountId = useCurrentAccountId();
  const { contextType } = useStatusContext();
  const statusUrl = status?.url ?? status?.uri;

  // Actions
  const dispatch = useAppDispatch();
  const handleReplyClick = useCallback(() => {
    dispatch(statusInteraction({ statusId, intent: 'reply', contextType }));
  }, [contextType, dispatch, statusId]);
  const handleFavouriteClick = useCallback(() => {
    dispatch(statusInteraction({ statusId, intent: 'favourite', contextType }));
  }, [contextType, dispatch, statusId]);
  const handleShareClick = useCallback(() => {
    if (!statusUrl) {
      return;
    }

    // We need to make this partial as by default share always is set, despite not being supported in FF.
    const nav = navigator as Partial<Pick<Navigator, 'share'>> &
      Pick<Navigator, 'clipboard'>;
    if (nav.share) {
      void nav.share({
        url: statusUrl,
      });
    } else {
      dispatch(statusInteraction({ statusId, intent: 'copy', contextType }));
    }
  }, [contextType, dispatch, statusId, statusUrl]);
  const handleBookmarkClick = useCallback(() => {
    dispatch(statusInteraction({ statusId, intent: 'bookmark', contextType }));
  }, [contextType, dispatch, statusId]);

  const intl = useIntl();

  const favouriteIcon = useIconWeight(HeartIcon, status?.favourited && 'fill');
  const bookmarkIcon = useIconWeight(
    BookmarkSimpleIcon,
    status?.bookmarked && 'fill',
  );

  if (!status) {
    return null;
  }

  const isPublic =
    status.visibility === 'public' || status.visibility === 'unlisted';

  const favouriteTitle = intl.formatMessage(
    status.favourited ? messages.removeFavourite : messages.favourite,
  );

  const isQuotingMe = quotedAccountId === currentAccountId;
  const shouldShowQuoteRemovalHint =
    isQuotingMe && contextType === 'notifications';

  return (
    <div className={classNames(classes.actions, classes.buttonAlign)}>
      <Button
        size='sm'
        variant='ghost'
        title={intl.formatMessage(messages.replyAll)}
        leadingIcon={ChatCircleTextIcon}
        onClick={handleReplyClick}
      >
        {withCounters && status.replies_count}
      </Button>

      <StatusReblogButton statusId={statusId}>
        {withCounters && status.reblogs_count}
      </StatusReblogButton>

      <ToggleButton
        size='sm'
        variant='ghost'
        active={status.favourited}
        title={favouriteTitle}
        leadingIcon={favouriteIcon}
        onClick={handleFavouriteClick}
        className={classes.actionsButtonGap}
      >
        {withCounters && status.favourites_count}
      </ToggleButton>

      {isPublic && (
        <IconButton
          size='sm'
          variant='ghost'
          icon={ShareFatIcon}
          onClick={handleShareClick}
        >
          <FormattedMessage id='status.share' defaultMessage='Share' />
        </IconButton>
      )}

      <ToggleIconButton
        size='sm'
        variant='ghost'
        active={status.bookmarked}
        icon={bookmarkIcon}
        onClick={handleBookmarkClick}
        aria-pressed={status.bookmarked}
      >
        {!status.bookmarked ? (
          <FormattedMessage id='status.bookmark' defaultMessage='Bookmark' />
        ) : (
          <FormattedMessage
            id='status.remove_bookmark'
            defaultMessage='Remove bookmark'
          />
        )}
      </ToggleIconButton>

      <RemoveQuoteHint
        className='status__action-bar__button-wrapper'
        canShowHint={shouldShowQuoteRemovalHint}
      >
        {(dismissQuoteHint) => (
          <StatusActionMenu
            dismissQuoteHint={dismissQuoteHint}
            status={status}
            withDismiss={withDismiss}
          />
        )}
      </RemoveQuoteHint>
    </div>
  );
};

const StatusReblogButton: React.FC<{
  statusId: string;
  children: React.ReactNode;
}> = ({ statusId, children }) => {
  const conditions = useAppSelector((state) =>
    selectStatusConditions(state, statusId),
  );
  const { isBoosted } = conditions;

  const boostState = boostItemState(conditions);
  const quoteState = quoteItemState(conditions);
  const intl = useIntl();

  const dispatch = useAppDispatch();
  const onReblog = useCallback(() => {
    dispatch(statusInteraction({ statusId, intent: 'reblog' }));
  }, [dispatch, statusId]);
  const onQuote = useCallback(() => {
    dispatch(statusInteraction({ statusId, intent: 'quote' }));
  }, [dispatch, statusId]);

  if (quickBoosting) {
    return (
      <ToggleButton
        size='sm'
        variant='ghost'
        active={isBoosted}
        leadingIcon={ArrowsClockwiseIcon}
        onClick={onReblog}
        disabled={boostState.disabled}
      >
        {children}
      </ToggleButton>
    );
  }

  return (
    <Menu>
      <MenuTrigger
        as={ToggleButton}
        size='sm'
        variant='ghost'
        active={isBoosted}
        leadingIcon={ArrowsClockwiseIcon}
      >
        {children}
      </MenuTrigger>

      <MenuList placement='bottom' maxWidth={180}>
        <MenuItem
          onClick={onReblog}
          icon={ArrowsClockwiseIcon}
          disabled={boostState.disabled}
          description={boostState.meta && intl.formatMessage(boostState.meta)}
        >
          {intl.formatMessage(boostState.title)}
        </MenuItem>
        <MenuItem
          onClick={onQuote}
          icon={QuotesFilledIcon}
          disabled={quoteState.disabled}
          description={quoteState.meta && intl.formatMessage(quoteState.meta)}
        >
          {intl.formatMessage(quoteState.title)}
        </MenuItem>
      </MenuList>
    </Menu>
  );
};

const QuotesFilledIcon = iconWeight(QuotesIcon, 'fill');

const StatusActionMenu: React.FC<{
  dismissQuoteHint: () => void;
  status: StatusShape;
  withDismiss?: boolean;
}> = ({ status, dismissQuoteHint, withDismiss }) => {
  const account = useAppSelector((state) => state.accounts.get(status.account));
  const { contextType } = useStatusContext();
  const { permissions } = useIdentity();
  const relationship = useRelationship(account?.id);
  const intl = useIntl();
  const dispatch = useAppDispatch();

  const conditions = useAppSelector((state) =>
    selectStatusConditions(state, status.id),
  );
  const interactions = useAppSelector((state) =>
    selectStatusInteractionsAllowed(state, status.id),
  );
  const statusInteractionFactory = useCallback(
    (intent: StatusInteractionIntent) => {
      return () => {
        dispatch(
          statusInteraction({ statusId: status.id, contextType, intent }),
        );
      };
    },
    [contextType, dispatch, status.id],
  );

  const menu = useMemo(
    () =>
      getMenuItems({
        status,
        account,
        conditions,
        interactions,
        onStatusInteraction: statusInteractionFactory,
        withDismiss,
        permissions,
        intl,
        relationship,
        dispatch,
      }),
    [
      status,
      account,
      conditions,
      interactions,
      statusInteractionFactory,
      withDismiss,
      permissions,
      intl,
      relationship,
      dispatch,
    ],
  );
  const onOpen = useCallback(() => {
    // Replicates needsStatusRefresh of the Dropdown component.
    if (quickBoosting && !status.quote_approval) {
      dispatch(
        fetchStatus(status.id, { forceFetch: true, alsoFetchContext: false }),
      );
    }

    dismissQuoteHint();
  }, [dismissQuoteHint, dispatch, status.id, status.quote_approval]);

  return (
    <Menu onOpen={onOpen}>
      <MenuTrigger
        as={IconButton}
        size='sm'
        variant='ghost'
        icon={DotsThreeIcon}
      >
        <FormattedMessage id='status.more' defaultMessage='More' />
      </MenuTrigger>

      <MenuList placement='top-end'>
        {menu.map((item, index) => (
          <StatusActionItem key={index} item={item} />
        ))}
      </MenuList>
    </Menu>
  );
};

const StatusActionItem: React.FC<{ item: DropdownItem }> = ({ item }) => {
  if (!item) {
    return <MenuItemDivider />;
  }

  const commonProps = {
    icon: item.icon,
    disabled: item.disabled,
    destructive: item.dangerous,
    children: item.text,
    description: item.description,
  } as const;

  if ('to' in item) {
    return <MenuItemLink {...commonProps} to={item.to} as='link' />;
  } else if ('href' in item) {
    return <MenuItemLink {...commonProps} href={item.href} as='a' />;
  }

  return <MenuItem {...commonProps} onClick={item.action} />;
};

interface MenuItemsParams {
  status: StatusShape;
  account?: Account;
  conditions: StatusConditions;
  interactions: StatusInteractionsAllowed;
  onStatusInteraction: (intent: StatusInteractionIntent) => () => void;
  withDismiss?: boolean;
  permissions: number;
  intl: ReturnType<typeof useIntl>;
  relationship?: Relationship | null;
  dispatch: AppDispatch;
}

function getMenuItems({
  status,
  account,
  conditions,
  interactions,
  onStatusInteraction,
  withDismiss,
  permissions,
  intl,
  relationship,
  dispatch,
}: MenuItemsParams) {
  const menu: DropdownItem[] = [];

  const statusId = status.id;
  const statusUrl = status.url ?? status.uri;
  const { isPublic, isLocal, isLoggedIn, isMine } = conditions;

  menu.push({
    text: intl.formatMessage(messages.open),
    to: `/@${account?.acct}/${statusId}`,
  });

  if (isPublic && !isLocal) {
    menu.push({
      text: intl.formatMessage(messages.openOriginalPage),
      href: statusUrl,
    });
  }

  menu.push({
    text: intl.formatMessage(messages.copy),
    action: onStatusInteraction('copy'),
  });

  if (isPublic && 'share' in navigator) {
    menu.push({
      text: intl.formatMessage(messages.share),
      action: () => {
        void navigator.share({
          url: statusUrl,
        });
      },
    });
  }

  if (interactions.embed) {
    menu.push({
      text: intl.formatMessage(messages.embed),
      action: onStatusInteraction('embed'),
    });
  }

  if (!isLoggedIn) {
    return menu;
  }

  if (quickBoosting) {
    menu.push(null);
    const quoteItem = quoteItemState(conditions);
    menu.push({
      text: intl.formatMessage(quoteItem.title),
      description: quoteItem.meta
        ? intl.formatMessage(quoteItem.meta)
        : undefined,
      disabled: quoteItem.disabled,
      action: onStatusInteraction('quote'),
    });
  }

  menu.push(null);

  if (interactions.pin) {
    menu.push({
      text: intl.formatMessage(status.pinned ? messages.unpin : messages.pin),
      action: onStatusInteraction('pin'),
    });
    menu.push(null);
  }

  if (interactions.mute || withDismiss) {
    menu.push({
      text: intl.formatMessage(
        status.muted ? messages.unmuteConversation : messages.muteConversation,
      ),
      action: onStatusInteraction('mute'),
    });
    if (interactions.editQuotePolicy && !isRedesignEnabled()) {
      menu.push({
        text: intl.formatMessage(messages.quotePolicyChange),
        action: onStatusInteraction('editQuotePolicy'),
      });
    }
    menu.push(null);
  }

  if (interactions.edit && interactions.delete && interactions.redraft) {
    menu.push({
      text: intl.formatMessage(messages.edit),
      action: onStatusInteraction('edit'),
    });
    menu.push({
      text: intl.formatMessage(messages.delete),
      action: onStatusInteraction('delete'),
      dangerous: true,
    });
    menu.push({
      text: intl.formatMessage(messages.redraft),
      action: onStatusInteraction('redraft'),
      dangerous: true,
    });
  }

  if (isMine || !account) {
    // Add the filter to handle the edge case of not having account data.
    if (interactions.filter) {
      menu.push(null);
      menu.push({
        text: intl.formatMessage(messages.filter),
        action: onStatusInteraction('filter'),
        dangerous: true,
      });
    }
    return menu;
  }

  if (!account.invalid_handle) {
    menu.push({
      text: intl.formatMessage(messages.mention, {
        name: account.username,
      }),
      action: () => {
        dispatch(mentionCompose(account));
      },
    });
    menu.push({
      text: intl.formatMessage(messages.direct, {
        name: account.username,
      }),
      action: () => {
        dispatch(directCompose(account));
      },
    });
    menu.push(null);
  }

  if (interactions.revokeQuote) {
    menu.push({
      text: intl.formatMessage(messages.revokeQuote, {
        name: account.username,
      }),
      action: onStatusInteraction('revokeQuote'),
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
        dispatch(unmuteAccount(account.id));
      } else {
        dispatch(muteAccount(account.id));
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
        dispatch(unblockAccount(account.id));
      } else {
        dispatch(initBlockModal(account));
      }
    },
    dangerous: !isBlocking,
  });

  if (interactions.filter) {
    menu.push(null);
    menu.push({
      text: intl.formatMessage(messages.filter),
      action: onStatusInteraction('filter'),
      dangerous: true,
    });
  }
  menu.push(null);

  menu.push({
    text: intl.formatMessage(messages.report, {
      name: account.username,
    }),
    action: onStatusInteraction('report'),
    dangerous: true,
  });

  const domain = account.acct.split('@')[1];

  if (!isLocal) {
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
          dispatch(initDomainBlockModal(account));
        }
      },
      dangerous: !isDomainBlocking,
    });
  }

  const canManageUsers =
    (permissions & PERMISSION_MANAGE_USERS) === PERMISSION_MANAGE_USERS;
  const canManageFederation =
    (permissions & PERMISSION_MANAGE_FEDERATION) ===
      PERMISSION_MANAGE_FEDERATION && !isLocal;

  if (!canManageUsers && !canManageFederation) {
    return menu;
  }

  menu.push(null);
  if (canManageUsers) {
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
  if (canManageFederation) {
    menu.push({
      text: intl.formatMessage(messages.admin_domain, {
        domain,
      }),
      href: `/admin/instances/${domain}`,
    });
  }

  return menu;
}
