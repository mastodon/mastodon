import type { List as ImmutableList, Map as ImmutableMap } from 'immutable';

import { apiUpdateMedia } from 'mastodon/api/compose';
import type { ApiMediaAttachmentJSON } from 'mastodon/api_types/media_attachments';
import type { MediaAttachment } from 'mastodon/models/media_attachment';
import { createDataLoadingThunk } from 'mastodon/store/typed_functions';

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
