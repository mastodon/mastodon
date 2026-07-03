import { defineMessages } from 'react-intl';

import {
  apiReblog,
  apiUnreblog,
  apiRevokeQuote,
  apiGetQuotes,
} from '@/mastodon/api/interactions';
import type { StatusContextType } from '@/mastodon/components/status/types';
import type { VisibilityModalCallback } from '@/mastodon/features/ui/components/visibility_modal';
import type { StatusShape, StatusVisibility } from '@/mastodon/models/status';
import {
  createAppThunk,
  createDataLoadingThunk,
} from '@/mastodon/store/typed_functions';

import { deleteModal } from '../initial_state';
import { selectStatusInteractions } from '../selectors/statuses';

import { showAlert, showGenericAlert } from './alerts';
import { replyCompose } from './compose';
import { quoteComposeById } from './compose_typed';
import { importFetchedStatus, importFetchedStatuses } from './importer';
import {
  bookmark,
  favourite,
  pin,
  unbookmark,
  unfavourite,
  unpin,
} from './interactions';
import { openModal } from './modal';
import {
  deleteStatus,
  editStatus,
  muteStatus,
  setStatusQuotePolicy,
  unmuteStatus,
} from './statuses';

export type StatusInteractionIntent =
  | 'bookmark'
  | 'delete'
  | 'editQuotePolicy'
  | 'edit'
  | 'embed'
  | 'favourite'
  | 'filter'
  | 'mute'
  | 'pin'
  | 'quote'
  | 'reblog'
  | 'redraft'
  | 'reply'
  | 'report'
  | 'revokeQuote';

const messages = defineMessages({
  noEdits: {
    id: 'status.cannot_edit',
    defaultMessage: 'You are not allowed to edit this post',
  },
  privateStatus: {
    id: 'status.public_only',
    defaultMessage: 'This post is private',
  },
  notQuoted: {
    id: 'status.not_quoted',
    defaultMessage: 'You are not quoted in this post',
  },
});

export const statusInteraction = createAppThunk(
  (
    {
      statusId,
      contextType,
      intent,
    }: {
      statusId: string;
      contextType?: StatusContextType;
      intent: StatusInteractionIntent;
    },
    { getState, dispatch },
  ) => {
    const state = getState();
    const statusImmutable = state.statuses.get(statusId);
    if (!statusImmutable) {
      dispatch(showGenericAlert());
      return;
    }
    const status = statusImmutable.toJS() as unknown as StatusShape;

    // Check the permissions and respond if it's not allowed.
    const interactions = selectStatusInteractions(state, statusId);
    const permissions = interactions[intent];
    if (!permissions.allowed) {
      // Must strictly check for false, as values can be undefined.
      if (permissions.isLoggedIn === false) {
        dispatch(
          openModal({
            modalType: 'INTERACTION',
            modalProps: {
              intent,
              accountId: status.account,
              url: status.uri,
            },
          }),
        );
      } else if (permissions.isMine === false) {
        dispatch(showAlert({ message: messages.noEdits }));
      } else if (
        permissions.isNotDirect === false ||
        permissions.isPublic === false
      ) {
        dispatch(showAlert({ message: messages.privateStatus }));
      } else if (permissions.isQuoted === false) {
        dispatch(showAlert({ message: messages.notQuoted }));
      }
      return;
    }

    // Handle intents for all statuses.
    switch (intent) {
      case 'bookmark':
        if (status.bookmarked) {
          dispatch(unbookmark(statusImmutable));
        } else {
          dispatch(bookmark(statusImmutable));
        }
        return;
      case 'delete':
        if (!deleteModal) {
          void dispatch(deleteStatus(statusId));
        } else {
          dispatch(
            openModal({
              modalType: 'CONFIRM_DELETE_STATUS',
              modalProps: { statusId },
            }),
          );
        }
        return;
      case 'edit': {
        const composerText = state.compose.get('text');
        if (typeof composerText === 'string' && composerText.trim()) {
          dispatch(
            openModal({
              modalType: 'CONFIRM_EDIT_STATUS',
              modalProps: { statusId },
            }),
          );
        } else {
          dispatch(editStatus(statusId));
        }
        return;
      }
      case 'editQuotePolicy':
        dispatch(
          openModal({
            modalType: 'COMPOSE_PRIVACY',
            modalProps: {
              statusId,
              onChange: ((_, policy) => {
                void dispatch(setStatusQuotePolicy({ statusId, policy }));
              }) satisfies VisibilityModalCallback,
            },
          }),
        );
        return;
      case 'embed':
        dispatch(
          openModal({
            modalType: 'EMBED',
            modalProps: { id: statusId },
          }),
        );
        return;
      case 'filter':
        dispatch(
          openModal({
            modalType: 'FILTER',
            modalProps: { statusId, contextType },
          }),
        );
        return;
      case 'favourite':
        if (status.favourited) {
          dispatch(unfavourite(statusImmutable));
        } else {
          dispatch(favourite(statusImmutable));
        }
        return;
      case 'mute':
        if (status.muted) {
          dispatch(unmuteStatus(statusId));
        } else {
          dispatch(muteStatus(statusId));
        }
        return;
      case 'pin':
        if (status.pinned) {
          dispatch(unpin(statusImmutable));
        } else {
          dispatch(pin(statusImmutable));
        }
        return;
      case 'quote':
        dispatch(quoteComposeById(statusId));
        return;
      case 'reblog':
        if (status.reblogged) {
          void dispatch(unreblog({ statusId }));
        } else {
          void dispatch(reblog({ statusId, visibility: status.visibility }));
        }
        return;
      case 'redraft':
        if (!deleteModal) {
          void dispatch(deleteStatus(statusId, true));
        } else {
          dispatch(
            openModal({
              modalType: 'CONFIRM_DELETE_STATUS',
              modalProps: {
                statusId,
                withRedraft: true,
              },
            }),
          );
        }
        return;
      case 'reply':
        dispatch(replyCompose(statusImmutable));
        return;
      case 'report':
        dispatch(
          openModal({
            modalType: 'REPORT',
            modalProps: {
              accountId: status.account,
              statusId: statusId,
            },
          }),
        );
        return;
      case 'revokeQuote':
        dispatch(
          openModal({
            modalType: 'CONFIRM_REVOKE_QUOTE',
            modalProps: {
              statusId: statusId,
              quotedStatusId: status.quote?.quoted_status,
            },
          }),
        );
        return;
    }
  },
);

export const reblog = createDataLoadingThunk(
  'status/reblog',
  ({
    statusId,
    visibility,
  }: {
    statusId: string;
    visibility: StatusVisibility;
  }) => apiReblog(statusId, visibility),
  (data, { dispatch, discardLoadData }) => {
    // The reblog API method returns a new status wrapped around the original. In this case we are only
    // interested in how the original is modified, hence passing it skipping the wrapper
    dispatch(importFetchedStatus(data.reblog));

    // The payload is not used in any actions
    return discardLoadData;
  },
);

export const unreblog = createDataLoadingThunk(
  'status/unreblog',
  ({ statusId }: { statusId: string }) => apiUnreblog(statusId),
  (data, { dispatch, discardLoadData }) => {
    dispatch(importFetchedStatus(data));

    // The payload is not used in any actions
    return discardLoadData;
  },
);

export const revokeQuote = createDataLoadingThunk(
  'status/revoke_quote',
  ({
    statusId,
    quotedStatusId,
  }: {
    statusId: string;
    quotedStatusId: string;
  }) => apiRevokeQuote(quotedStatusId, statusId),
  (data, { dispatch, discardLoadData }) => {
    dispatch(importFetchedStatus(data));

    return discardLoadData;
  },
);

export const fetchQuotes = createDataLoadingThunk(
  'status/fetch_quotes',
  async ({ statusId, next }: { statusId: string; next?: string }) => {
    const { links, statuses } = await apiGetQuotes(statusId, next);

    return {
      links,
      statuses,
      replace: !next,
    };
  },
  (payload, { dispatch }) => {
    dispatch(importFetchedStatuses(payload.statuses));
  },
);
