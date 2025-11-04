import { defineMessages } from 'react-intl';

import { createAction } from '@reduxjs/toolkit';
import type { List as ImmutableList, Map as ImmutableMap } from 'immutable';

import { apiUpdateMedia } from 'mastodon/api/compose';
import { apiGetSearch } from 'mastodon/api/search';
import type { ApiMediaAttachmentJSON } from 'mastodon/api_types/media_attachments';
import type { MediaAttachment } from 'mastodon/models/media_attachment';
import {
  createDataLoadingThunk,
  createAppThunk,
} from 'mastodon/store/typed_functions';

import type { ApiQuotePolicy } from '../api_types/quotes';
import type { Status, StatusVisibility } from '../models/status';
import type { RootState } from '../store';

import { showAlert } from './alerts';
import { changeCompose, focusCompose } from './compose';
import { importFetchedStatuses } from './importer';
import { openModal } from './modal';

const messages = defineMessages({
  quoteErrorEdit: {
    id: 'quote_error.edit',
    defaultMessage: 'Quotes cannot be added when editing a post.',
  },
  quoteErrorUpload: {
    id: 'quote_error.upload',
    defaultMessage: 'Quoting is not allowed with media attachments.',
  },
  quoteErrorPoll: {
    id: 'quote_error.poll',
    defaultMessage: 'Quoting is not allowed with polls.',
  },
  quoteErrorQuote: {
    id: 'quote_error.quote',
    defaultMessage: 'Only one quote at a time is allowed.',
  },
  quoteErrorUnauthorized: {
    id: 'quote_error.unauthorized',
    defaultMessage: 'You are not authorized to quote this post.',
  },
  quoteErrorPrivateMention: {
    id: 'quote_error.private_mentions',
    defaultMessage: 'Quoting is not allowed with direct mentions.',
  },
});

type SimulatedMediaAttachmentJSON = ApiMediaAttachmentJSON & {
  unattached?: boolean;
};

const simulateModifiedApiResponse = (
  media: MediaAttachment,
  params: { description?: string; focus?: string },
): SimulatedMediaAttachmentJSON => {
  const [x, y] = (params.focus ?? '').split(',');

  const data = {
    ...media.toJS(),
    ...params,
    meta: {
      focus: {
        x: parseFloat(x ?? '0'),
        y: parseFloat(y ?? '0'),
      },
    },
  } as unknown as SimulatedMediaAttachmentJSON;

  return data;
};

export const changeComposeVisibility = createAppThunk(
  'compose/visibility_change',
  (visibility: StatusVisibility, { dispatch, getState }) => {
    if (visibility !== 'direct') {
      return visibility;
    }

    const state = getState();
    const quotedStatusId = state.compose.get('quoted_status_id') as
      | string
      | null;
    if (!quotedStatusId) {
      return visibility;
    }

    // Remove the quoted status
    dispatch(quoteComposeCancel());
    const quotedStatus = state.statuses.get(quotedStatusId) as Status | null;
    if (!quotedStatus) {
      return visibility;
    }

    // Append the quoted status URL to the compose text
    const url = quotedStatus.get('url') as string;
    const text = state.compose.get('text') as string;
    if (!text.includes(url)) {
      const newText = text.trim() ? `${text}\n\n${url}` : url;
      dispatch(changeCompose(newText));
    }
    return visibility;
  },
);

export const changeUploadCompose = createDataLoadingThunk(
  'compose/changeUpload',
  async (
    {
      id,
      ...params
    }: {
      id: string;
      description: string;
      focus: string;
    },
    { getState },
  ) => {
    const media = (
      (getState().compose as ImmutableMap<string, unknown>).get(
        'media_attachments',
      ) as ImmutableList<MediaAttachment>
    ).find((item) => item.get('id') === id);

    // Editing already-attached media is deferred to editing the post itself.
    // For simplicity's sake, fake an API reply.
    if (media && !media.get('unattached')) {
      return new Promise<SimulatedMediaAttachmentJSON>((resolve) => {
        resolve(simulateModifiedApiResponse(media, params));
      });
    }

    return apiUpdateMedia(id, params);
  },
  (media: SimulatedMediaAttachmentJSON) => {
    return {
      media,
      attached: typeof media.unattached !== 'undefined' && !media.unattached,
    };
  },
  {
    useLoadingBar: false,
  },
);

export const quoteCompose = createAppThunk(
  'compose/quoteComposeStatus',
  (status: Status, { dispatch }) => {
    dispatch(focusCompose());
    return status;
  },
);

export const quoteComposeByStatus = createAppThunk(
  (status: Status, { dispatch, getState }) => {
    const state = getState();
    const composeState = state.compose;
    const mediaAttachments = composeState.get('media_attachments');
    // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
    const wasQuietPostHintModalDismissed: boolean =
      // eslint-disable-next-line @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access
      state.settings.getIn(
        ['dismissed_banners', 'quote/quiet_post_hint'],
        false,
      );

    if (composeState.get('id')) {
      dispatch(showAlert({ message: messages.quoteErrorEdit }));
    } else if (composeState.get('privacy') === 'direct') {
      dispatch(showAlert({ message: messages.quoteErrorPrivateMention }));
    } else if (composeState.get('poll')) {
      dispatch(showAlert({ message: messages.quoteErrorPoll }));
    } else if (
      composeState.get('is_uploading') ||
      (mediaAttachments &&
        typeof mediaAttachments !== 'string' &&
        typeof mediaAttachments !== 'number' &&
        typeof mediaAttachments !== 'boolean' &&
        mediaAttachments.size !== 0)
    ) {
      dispatch(showAlert({ message: messages.quoteErrorUpload }));
    } else if (composeState.get('quoted_status_id')) {
      dispatch(showAlert({ message: messages.quoteErrorQuote }));
    } else if (
      status.getIn(['quote_approval', 'current_user']) !== 'automatic' &&
      status.getIn(['quote_approval', 'current_user']) !== 'manual'
    ) {
      dispatch(showAlert({ message: messages.quoteErrorUnauthorized }));
    } else if (
      status.get('visibility') === 'unlisted' &&
      !wasQuietPostHintModalDismissed
    ) {
      dispatch(
        openModal({
          modalType: 'CONFIRM_QUIET_QUOTE',
          modalProps: { status },
        }),
      );
    } else {
      dispatch(quoteCompose(status));
    }
  },
);

export const quoteComposeById = createAppThunk(
  (statusId: string, { dispatch, getState }) => {
    const status = getState().statuses.get(statusId);
    if (status) {
      dispatch(quoteComposeByStatus(status));
    }
  },
);

const composeStateForbidsLink = (composeState: RootState['compose']) => {
  return (
    composeState.get('quoted_status_id') ||
    composeState.get('is_submitting') ||
    composeState.get('poll') ||
    composeState.get('is_uploading') ||
    composeState.get('id') ||
    composeState.get('privacy') === 'direct'
  );
};

export const pasteLinkCompose = createDataLoadingThunk(
  'compose/pasteLink',
  async ({ url }: { url: string }) => {
    return await apiGetSearch({
      q: url,
      type: 'statuses',
      resolve: true,
      limit: 2,
    });
  },
  (data, { dispatch, getState, requestId }) => {
    const composeState = getState().compose;

    if (
      composeStateForbidsLink(composeState) ||
      composeState.get('fetching_link') !== requestId // Request has been cancelled
    )
      return;

    dispatch(importFetchedStatuses(data.statuses));

    if (
      data.statuses.length === 1 &&
      data.statuses[0] &&
      ['automatic', 'manual'].includes(
        data.statuses[0].quote_approval?.current_user ?? 'denied',
      )
    ) {
      dispatch(quoteComposeById(data.statuses[0].id));
    }
  },
  {
    useLoadingBar: false,
    condition: (_, { getState }) =>
      !getState().compose.get('fetching_link') &&
      !composeStateForbidsLink(getState().compose),
  },
);

// Ideally this would cancel the action and the HTTP request, but this is good enough
export const cancelPasteLinkCompose = createAction(
  'compose/cancelPasteLinkCompose',
);

export const quoteComposeCancel = createAction('compose/quoteComposeCancel');

export const setComposeQuotePolicy = createAction<ApiQuotePolicy>(
  'compose/setQuotePolicy',
);
