import { defineMessages } from 'react-intl';

import { createAction } from '@reduxjs/toolkit';
import type { List as ImmutableList, Map as ImmutableMap } from 'immutable';

import { apiUpdateMedia } from 'mastodon/api/compose';
import type { ApiMediaAttachmentJSON } from 'mastodon/api_types/media_attachments';
import type { MediaAttachment } from 'mastodon/models/media_attachment';
import {
  createDataLoadingThunk,
  createAppThunk,
} from 'mastodon/store/typed_functions';

import type { ApiQuotePolicy } from '../api_types/quotes';
import type { Status } from '../models/status';

import { showAlert } from './alerts';
import { focusCompose } from './compose';

const messages = defineMessages({
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
    const composeState = getState().compose;
    const mediaAttachments = composeState.get('media_attachments');

    if (composeState.get('poll')) {
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

export const quoteComposeCancel = createAction('compose/quoteComposeCancel');

export const setComposeQuotePolicy = createAction<ApiQuotePolicy>(
  'compose/setQuotePolicy',
);
