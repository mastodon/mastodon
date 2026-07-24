import { defineMessages } from 'react-intl';

import { createAction } from '@reduxjs/toolkit';
import type { List as ImmutableList, Map as ImmutableMap } from 'immutable';

import { apiUpdateMedia } from '@/mastodon/api/compose';
import { apiGetSearch } from '@/mastodon/api/search';
import type { ApiMediaAttachmentJSON } from '@/mastodon/api_types/media_attachments';
import type { ApiQuotePolicy } from '@/mastodon/api_types/quotes';
import type { MediaAttachment } from '@/mastodon/models/media_attachment';
import type { Status, StatusVisibility } from '@/mastodon/models/status';
import type { RootState } from '@/mastodon/store';
import {
  createDataLoadingThunk,
  createAppThunk,
} from '@/mastodon/store/typed_functions';

import type { ApiStatusJSON } from '../api_types/statuses';

import { showAlert } from './alerts';
import {
  changeCompose,
  focusCompose,
  submitCompose as submitComposeApi,
  uploadCompose,
} from './compose';
import { importFetchedStatuses } from './importer';
import { openModal } from './modal';

export const PRIVATE_QUOTE_MODAL_ID = 'quote/private_notify';

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
  attached?: boolean;
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
    attached: true,
  } as SimulatedMediaAttachmentJSON;

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
      attached: typeof media.attached !== 'undefined' && media.attached,
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

    const wasQuietPostHintModalDismissed = !!state.settings.getIn(
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

export const setDragUploadEnabled = createAction<boolean>(
  'compose/setDragUploadEnabled',
);

export const submitCompose = createAppThunk(
  (
    {
      textareaValue = '',
      redirectOnSuccess,
    }: { textareaValue?: string; redirectOnSuccess?: boolean },
    { getState, dispatch },
  ) => {
    if (
      textareaValue &&
      (getState().compose.get('text') as string) !== textareaValue
    ) {
      dispatch(changeCompose(textareaValue));
    }

    const { compose, meta, statuses, settings } = getState();
    const privacy = compose.get('privacy') as StatusVisibility;
    const missingAltText = (
      compose.get('media_attachments') as unknown as Immutable.List<
        Immutable.Map<string, string>
      >
    ).some(
      (media) =>
        ['image', 'gifv'].includes(media.get('type') ?? '') &&
        (media.get('description') ?? '').length === 0,
    );
    const me = meta.get('me') as string | null;
    const quotedStatusId = compose.get('quoted_status_id') as string | null;
    const quoteToPrivate =
      !!quotedStatusId &&
      privacy === 'private' &&
      statuses.getIn([quotedStatusId, 'account']) !== me &&
      !settings.getIn(['dismissed_banners', PRIVATE_QUOTE_MODAL_ID]);

    if (
      !!meta.get('missing_alt_text_modal') &&
      missingAltText &&
      privacy !== 'direct'
    ) {
      dispatch(
        openModal({
          modalType: 'CONFIRM_MISSING_ALT_TEXT',
          modalProps: {},
        }),
      );
    } else if (quoteToPrivate) {
      dispatch(
        openModal({
          modalType: 'CONFIRM_PRIVATE_QUOTE_NOTIFY',
          modalProps: {},
        }),
      );
    } else {
      dispatch(
        submitComposeApi((status: ApiStatusJSON) => {
          if (redirectOnSuccess) {
            window.location.assign(status.url);
          }
        }),
      );
    }
  },
);

const urlLikeRegex = /^https?:\/\/[^\s]+\/[^\s]+$/i;

export const processPasteOrDrop = createAppThunk(
  (transfer: DataTransfer, { dispatch }) => {
    if (transfer.files.length === 1) {
      dispatch(uploadCompose(transfer.files));
    } else if (transfer.files.length === 0) {
      const data = transfer.getData('text/plain');
      if (!urlLikeRegex.exec(data)) return;

      try {
        const url = new URL(data).toString();
        void dispatch(pasteLinkCompose({ url }));
      } catch {}
    }
  },
);
