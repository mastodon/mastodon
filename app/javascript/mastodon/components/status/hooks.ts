import { useCallback, useMemo } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { useHistory } from 'react-router';

import { mentionComposeById } from '@/mastodon/actions/compose';
import type { StatusInteractionIntent } from '@/mastodon/actions/interactions_typed';
import { statusInteraction } from '@/mastodon/actions/interactions_typed';
import { openModal } from '@/mastodon/actions/modal';
import { toggleStatusSpoilers } from '@/mastodon/actions/statuses';
import { useExpandedStatus } from '@/mastodon/hooks/useStatus';
import { useToggle } from '@/mastodon/hooks/useToggle';
import type { ExpandedStatusShape } from '@/mastodon/models/status';
import { selectStatusFilters } from '@/mastodon/selectors/filters';
import { useAppSelector, useAppDispatch } from '@/mastodon/store';

import { FOCUS_TARGET } from '../navigation_focus_target';

import type { StatusContextType } from './types';

const messages = defineMessages({
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

export function useStatusHandlers({
  status,
  contextType,
  onClick,
}: {
  status?: ExpandedStatusShape;
  contextType?: StatusContextType;
  onClick?: () => void;
}) {
  const matchedFilters = useAppSelector((state) =>
    selectStatusFilters(state, {}),
  );
  const [showDespiteFilter, { onToggle: onFilterToggle }] = useToggle(false);

  const dispatch = useAppDispatch();
  const statusId = status?.id;

  // Display handlers
  const onExpandedToggle = useCallback(() => {
    dispatch(toggleStatusSpoilers(statusId));
  }, [dispatch, statusId]);

  const onToggleHidden = useCallback(() => {
    if (!status) {
      return;
    }
    if (!matchedFilters.length || showDespiteFilter) {
      dispatch(toggleStatusSpoilers(status.id));
    }

    if (!status.hidden || !status.spoiler_text) {
      onFilterToggle();
    }
  }, [
    dispatch,
    matchedFilters.length,
    onFilterToggle,
    showDespiteFilter,
    status,
  ]);

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

  const onOpen = useCallback(
    (newTab = false) => {
      if (onClick || !status) {
        onClick?.();
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
    [history, onClick, status],
  );

  const onOpenClick: React.MouseEventHandler = useCallback(
    (event) => {
      event.preventDefault();

      if (event.button === 0 && !(event.ctrlKey || event.metaKey)) {
        onOpen();
      } else if (
        event.button === 1 ||
        (event.button === 0 && (event.ctrlKey || event.metaKey))
      ) {
        onOpen(true);
      }
    },
    [onOpen],
  );

  const onHeaderClick: React.MouseEventHandler = useCallback(
    (event) => {
      // Only handle clicks on the empty space above the content
      if (event.target !== event.currentTarget && event.detail >= 1) {
        return;
      }

      onOpenClick(event);
    },
    [onOpenClick],
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
      showDespiteFilter,
      onOpenClick,
      onExpandedToggle,
      onFilterToggle,
      onHeaderClick,
      onMention,
      onOpen,
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
      handlerFactory,
      onExpandedToggle,
      onFilterToggle,
      onHeaderClick,
      onMention,
      onOpen,
      onOpenClick,
      onOpenMedia,
      onOpenProfile,
      onToggleHidden,
      showDespiteFilter,
    ],
  );
}
export type StatusHandlers = ReturnType<typeof useStatusHandlers>;

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
      isQuote ? intl.formatMessage(messages.quote_noun) : undefined,
      displayName.length === 0
        ? status.account.acct.split('@')[0]
        : displayName,
      spoilerText && status.hidden ? spoilerText : contentText,
      status.quote ? intl.formatMessage(messages.contains_quote) : undefined,
      intl.formatDate(status.created_at, {
        hour: '2-digit',
        minute: '2-digit',
        month: 'short',
        day: 'numeric',
      }),
      status.account.acct,
      reblogAcct
        ? intl.formatMessage(messages.boosted, { name: reblogAcct })
        : false,
    ].filter((val) => !!val);

    return values.join(', ');
  }, [intl, isQuote, reblogAcct, status]);
}
