import { createContext, createElement, use, useCallback, useMemo } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { useHistory } from 'react-router';

import {
  followAccount,
  muteAccount,
  unblockAccount,
  unmuteAccount,
} from '@/mastodon/actions/accounts';
import { initBlockModal } from '@/mastodon/actions/blocks';
import {
  mentionComposeById,
  directCompose,
  mentionCompose,
} from '@/mastodon/actions/compose';
import {
  initDomainBlockModal,
  unblockDomain,
} from '@/mastodon/actions/domain_blocks';
import type { StatusInteractionIntent } from '@/mastodon/actions/interactions_typed';
import { statusInteraction } from '@/mastodon/actions/interactions_typed';
import { openModal } from '@/mastodon/actions/modal';
import { toggleStatusSpoilers } from '@/mastodon/actions/statuses';
import { useRelationship } from '@/mastodon/hooks/useRelationship';
import { useExpandedStatus } from '@/mastodon/hooks/useStatus';
import { useToggle } from '@/mastodon/hooks/useToggle';
import { useIdentity } from '@/mastodon/identity_context';
import { quickBoosting } from '@/mastodon/initial_state';
import type { MenuItem as DropdownItem } from '@/mastodon/models/dropdown_menu';
import type { Relationship } from '@/mastodon/models/relationship';
import type {
  AccountStatusShape,
  ExpandedStatusShape,
  StatusShape,
} from '@/mastodon/models/status';
import {
  PERMISSION_MANAGE_FEDERATION,
  PERMISSION_MANAGE_USERS,
} from '@/mastodon/permissions';
import { selectStatusFilters } from '@/mastodon/selectors/filters';
import type {
  StatusConditions,
  StatusInteractionsAllowed,
} from '@/mastodon/selectors/statuses';
import {
  selectStatusConditions,
  selectStatusInteractionsAllowed,
} from '@/mastodon/selectors/statuses';
import { useAppSelector, useAppDispatch } from '@/mastodon/store';
import type { AppDispatch } from '@/mastodon/store';
import { isRedesignEnabled } from '@/mastodon/utils/environment';
import type { OnElementHandler } from '@/mastodon/utils/html';

import { FOCUS_TARGET } from '../navigation_focus_target';

import { quoteItemState } from './boost_button_utils';
import { useElementHandledLink } from './handled_link';
import type { StatusContextType } from './types';

export const StatusContext = createContext<{
  id?: string | null;
  contextType?: StatusContextType;
}>({});

export function useStatusContext() {
  return use(StatusContext);
}

export function useStatusHandlers({
  status,
  contextType,
  onOpen,
}: {
  status?: ExpandedStatusShape;
  contextType?: StatusContextType;
  onOpen?: () => void;
}) {
  const { filterAction } = useAppSelector((state) =>
    selectStatusFilters(state, { contextType, statusId: status?.id }),
  );
  const [showDespiteFilter, { onToggle: onFilterToggle }] = useToggle(false);

  const dispatch = useAppDispatch();
  const statusId = status?.id;

  // Display handlers
  const onToggleHidden = useCallback(() => {
    if (!status) {
      return;
    }
    if (!filterAction || showDespiteFilter) {
      dispatch(toggleStatusSpoilers(status.id));
    }

    if (!status.hidden || !status.spoiler_text) {
      onFilterToggle();
    }
  }, [dispatch, filterAction, onFilterToggle, showDespiteFilter, status]);

  // Interaction handlers
  const handlerFactory = useCallback(
    (intent: StatusInteractionIntent) => {
      return () => {
        dispatch(statusInteraction({ statusId, intent, contextType }));
      };
    },
    [contextType, dispatch, statusId],
  );

  const accountId = status?.account.id;
  const onMention = useCallback(() => {
    dispatch(mentionComposeById(accountId));
  }, [dispatch, accountId]);

  // Navigation handlers
  const history = useHistory();

  const onOpenCallback = useCallback(
    (newTab = false) => {
      if (onOpen || !status) {
        onOpen?.();
        return;
      }

      const path = `/@${status.account.acct}/${status.id}`;

      if (newTab) {
        window.open(path, '_blank', 'noopener');
      } else if (history.location.pathname.replace('/deck/', '/') === path) {
        history.replace(path, { focusTarget: FOCUS_TARGET.POST });
      } else {
        history.push(path, { focusTarget: FOCUS_TARGET.POST });
      }
    },
    [history, onOpen, status],
  );

  const onOpenClick: React.MouseEventHandler = useCallback(
    (event) => {
      const target = event.target;
      if (
        !(target instanceof HTMLElement) ||
        target.closest('a, button') ||
        contextType === 'detailed'
      ) {
        return;
      }
      event.preventDefault();

      if (event.button === 0 && !(event.ctrlKey || event.metaKey)) {
        onOpenCallback();
      } else if (
        event.button === 1 ||
        (event.button === 0 && (event.ctrlKey || event.metaKey))
      ) {
        onOpenCallback(true);
      }
    },
    [contextType, onOpenCallback],
  );

  const acct = status?.account.acct;
  const onOpenProfile = useCallback(() => {
    if (acct) {
      history.push(`/@${acct}`);
    }
  }, [history, acct]);

  const onOpenMedia = useCallback(() => {
    const attachment = status?.media_attachments[0];
    if (!attachment) {
      return;
    }

    const lang = status.translation?.language ?? status.language;
    if (attachment.type === 'video') {
      dispatch(
        openModal({
          modalType: 'VIDEO',
          modalProps: {
            statusId: status.id,
            media: attachment,
            lang,
            options: { startTime: 0 },
          },
        }),
      );
    } else {
      dispatch(
        openModal({
          modalType: 'MEDIA',
          modalProps: {
            statusId: status.id,
            media: status.media_attachments,
            lang,
            index: 0,
          },
        }),
      );
    }
  }, [dispatch, status]);

  return useMemo(
    () => ({
      isFiltered: !!filterAction,
      showDespiteFilter,
      onOpenClick,
      onFilterToggle,
      onMention,
      onOpenCallback: () => {
        onOpenCallback();
      },
      onOpenMedia,
      onOpenProfile,
      onToggleHidden,
      onReply: handlerFactory('reply'),
      onFavourite: handlerFactory('favourite'),
      onBoost: handlerFactory('reblog'),
      onQuote: handlerFactory('quote'),
      onTranslate: handlerFactory('translate'),
    }),
    [
      filterAction,
      handlerFactory,
      onFilterToggle,
      onMention,
      onOpenCallback,
      onOpenClick,
      onOpenMedia,
      onOpenProfile,
      onToggleHidden,
      showDespiteFilter,
    ],
  );
}
export type StatusHandlers = ReturnType<typeof useStatusHandlers>;

const screenReaderMessages = defineMessages({
  quote_noun: {
    id: 'status.quote_noun',
    defaultMessage: 'Quote',
    description: 'Quote as a noun',
  },
  contains_quote: {
    id: 'status.contains_quote',
    defaultMessage: 'Contains quote',
  },
  boosted: { id: 'status.reblogged_by', defaultMessage: '{name} boosted' },
});

const domParser = new DOMParser();
export function useTextForScreenReader({
  statusId,
  reblogAcct,
  isQuote = false,
}: {
  statusId?: string | null;
  reblogAcct?: string;
  isQuote?: boolean;
}) {
  const intl = useIntl();
  const status = useExpandedStatus(statusId);
  return useMemo(() => {
    if (!status) {
      return '';
    }
    const displayName = status.account.display_name;

    const spoilerText = status.translation?.spoiler_text ?? status.spoiler_text;
    const contentHtml = status.translation?.contentHtml ?? status.contentHtml;
    const contentText = domParser.parseFromString(contentHtml, 'text/html')
      .documentElement.textContent;

    const values = [
      isQuote ? intl.formatMessage(screenReaderMessages.quote_noun) : undefined,
      displayName.length === 0
        ? status.account.acct.split('@')[0]
        : displayName,
      spoilerText && status.hidden ? spoilerText : contentText,
      status.quote
        ? intl.formatMessage(screenReaderMessages.contains_quote)
        : undefined,
      intl.formatDate(status.created_at, {
        hour: '2-digit',
        minute: '2-digit',
        month: 'short',
        day: 'numeric',
      }),
      status.account.acct,
      reblogAcct
        ? intl.formatMessage(screenReaderMessages.boosted, { name: reblogAcct })
        : false,
    ].filter((val) => !!val);

    return values.join(', ');
  }, [intl, isQuote, reblogAcct, status]);
}

export function useHandlersForStatus(
  status?: Pick<
    StatusShape | ExpandedStatusShape,
    'account' | 'mentions' | 'tagged_collections'
  > | null,
) {
  const hrefToMention = useCallback(
    (href: string) => status?.mentions.find((item) => item.url === href),
    [status?.mentions],
  );
  const hrefToCollectionId = useCallback(
    (href: string) =>
      status?.tagged_collections.find((item) => item.url === href)?.id,
    [status?.tagged_collections],
  );
  return useElementHandledLink({
    hashtagAccountId:
      typeof status?.account === 'string' ? status.account : status?.account.id,
    hrefToCollectionId,
    hrefToMention,
  });
}

export const onStatusLinksDisabled: OnElementHandler<AccountStatusShape> = (
  element,
  { key, href },
  children,
  status,
) => {
  // If this is a paragraph with just a link and it matches the card, don't add it.
  if (
    element instanceof HTMLParagraphElement &&
    element.children.length === 1 &&
    element.firstChild instanceof HTMLAnchorElement &&
    element.firstChild.href === status.card?.url
  ) {
    return null;
  } else if (element instanceof HTMLAnchorElement) {
    if (href === status.card?.url) {
      return null;
    }
    // Just use createElement instead of making the whole file JSX.
    return createElement('strong', { key: key as string }, children);
  }
  return undefined;
};

const menuMessages = defineMessages({
  delete: { id: 'status.delete', defaultMessage: 'Delete' },
  redraft: { id: 'status.redraft', defaultMessage: 'Delete & re-draft' },
  edit: { id: 'status.edit', defaultMessage: 'Edit' },
  follow: { id: 'status.follow', defaultMessage: 'Follow @{name}' },
  direct: { id: 'status.direct', defaultMessage: 'Privately mention @{name}' },
  mention: { id: 'status.mention', defaultMessage: 'Mention @{name}' },
  mute: { id: 'account.mute', defaultMessage: 'Mute @{name}' },
  muteBoosts: {
    id: 'account.mute_boosts',
    defaultMessage: 'Mute boosts from @{name}',
  },
  unmuteBoosts: {
    id: 'account.unmute_boosts',
    defaultMessage: 'Unmute boosts from @{name}',
  },
  block: { id: 'account.block', defaultMessage: 'Block @{name}' },
  share: { id: 'status.share', defaultMessage: 'Share' },
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

export function useStatusMenuActions({
  status,
  contextType,
  withDismiss = false,
}: {
  status: Omit<AccountStatusShape, 'reblog'>;
  withDismiss?: boolean;
  contextType?: StatusContextType;
}) {
  const account = status.account;
  const { permissions } = useIdentity();
  const relationship = useRelationship(account.id);
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

  return useMemo(
    () =>
      getMenuItems({
        status,
        conditions,
        interactions,
        onStatusInteraction: statusInteractionFactory,
        withDismiss,
        permissions,
        intl,
        relationship,
        contextType,
        dispatch,
      }),
    [
      status,
      conditions,
      interactions,
      statusInteractionFactory,
      withDismiss,
      permissions,
      intl,
      relationship,
      contextType,
      dispatch,
    ],
  );
}

interface MenuItemsParams {
  status: AccountStatusShape;
  conditions: StatusConditions;
  interactions: StatusInteractionsAllowed;
  onStatusInteraction: (intent: StatusInteractionIntent) => () => void;
  withDismiss?: boolean;
  permissions: number;
  intl: ReturnType<typeof useIntl>;
  relationship?: Relationship | null;
  contextType?: StatusContextType;
  dispatch: AppDispatch;
}

function getMenuItems({
  status,
  conditions,
  interactions,
  onStatusInteraction,
  withDismiss,
  permissions,
  intl,
  relationship,
  contextType,
  dispatch,
}: MenuItemsParams) {
  const menu: DropdownItem[] = [];

  const statusId = status.id;
  const account = status.account;
  const statusUrl = status.url ?? status.uri;
  const { isPublic, isLocal, isLoggedIn, isMine } = conditions;

  if (contextType !== 'detailed') {
    menu.push({
      text: intl.formatMessage(menuMessages.open),
      to: `/@${account.acct}/${statusId}`,
    });
  }

  if (isPublic && !isLocal) {
    menu.push({
      text: intl.formatMessage(menuMessages.openOriginalPage),
      href: statusUrl,
    });
  }

  menu.push({
    text: intl.formatMessage(menuMessages.copy),
    action: onStatusInteraction('copy'),
  });

  if (isPublic && 'share' in navigator) {
    menu.push({
      text: intl.formatMessage(menuMessages.share),
      action: () => {
        void navigator.share({
          url: statusUrl,
        });
      },
    });
  }

  if (interactions.embed) {
    menu.push({
      text: intl.formatMessage(menuMessages.embed),
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
      text: intl.formatMessage(
        status.pinned ? menuMessages.unpin : menuMessages.pin,
      ),
      action: onStatusInteraction('pin'),
    });
    menu.push(null);
  }

  if (interactions.mute || withDismiss) {
    menu.push({
      text: intl.formatMessage(
        status.muted
          ? menuMessages.unmuteConversation
          : menuMessages.muteConversation,
      ),
      action: onStatusInteraction('mute'),
    });
    if (interactions.editQuotePolicy && !isRedesignEnabled()) {
      menu.push({
        text: intl.formatMessage(menuMessages.quotePolicyChange),
        action: onStatusInteraction('editQuotePolicy'),
      });
    }
    menu.push(null);
  }

  if (interactions.edit && interactions.delete && interactions.redraft) {
    menu.push({
      text: intl.formatMessage(menuMessages.edit),
      action: onStatusInteraction('edit'),
    });
    menu.push({
      text: intl.formatMessage(menuMessages.delete),
      action: onStatusInteraction('delete'),
      dangerous: true,
    });
    menu.push({
      text: intl.formatMessage(menuMessages.redraft),
      action: onStatusInteraction('redraft'),
      dangerous: true,
    });
  }

  if (isMine) {
    // Add the filter to handle the edge case of not having account data.
    if (interactions.filter) {
      menu.push(null);
      menu.push({
        text: intl.formatMessage(menuMessages.filter),
        action: onStatusInteraction('filter'),
        dangerous: true,
      });
    }
    return menu;
  }

  if (!account.invalid_handle) {
    if (relationship && !relationship.following) {
      menu.push({
        text: intl.formatMessage(menuMessages.follow, {
          name: account.username,
        }),
        action: () => {
          dispatch(followAccount(account.id));
        },
      });
    }

    menu.push({
      text: intl.formatMessage(menuMessages.mention, {
        name: account.username,
      }),
      action: () => {
        dispatch(mentionCompose(account));
      },
    });
    menu.push({
      text: intl.formatMessage(menuMessages.direct, {
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
      text: intl.formatMessage(menuMessages.revokeQuote, {
        name: account.username,
      }),
      action: onStatusInteraction('revokeQuote'),
      dangerous: true,
    });
  }

  if (relationship?.following && !relationship.muting) {
    const isMutingBoosts = relationship.showing_reblogs;
    menu.push({
      text: intl.formatMessage(
        isMutingBoosts ? menuMessages.muteBoosts : menuMessages.unmuteBoosts,
        { name: account.username },
      ),
      action: () => {
        dispatch(
          followAccount(account.id, {
            reblogs: !isMutingBoosts,
          }),
        );
      },
      dangerous: true,
    });
  }

  const isMuted = !!relationship?.muting;
  menu.push({
    text: intl.formatMessage(
      isMuted ? menuMessages.unmute : menuMessages.mute,
      {
        name: account.username,
      },
    ),
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
    text: intl.formatMessage(
      isBlocking ? menuMessages.unblock : menuMessages.block,
      {
        name: account.username,
      },
    ),
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
      text: intl.formatMessage(menuMessages.filter),
      action: onStatusInteraction('filter'),
      dangerous: true,
    });
  }
  menu.push(null);

  menu.push({
    text: intl.formatMessage(menuMessages.report, {
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
        isDomainBlocking
          ? menuMessages.unblockDomain
          : menuMessages.blockDomain,
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
      text: intl.formatMessage(menuMessages.admin_account, {
        name: account.username,
      }),
      href: `/admin/accounts/${account.id}`,
    });
    menu.push({
      text: intl.formatMessage(menuMessages.admin_status),
      href: `/admin/accounts/${account.id}/statuses/${status.id}`,
    });
  }
  if (canManageFederation) {
    menu.push({
      text: intl.formatMessage(menuMessages.admin_domain, {
        domain,
      }),
      href: `/admin/instances/${domain}`,
    });
  }

  return menu;
}
