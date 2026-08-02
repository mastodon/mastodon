import type { CompactEmoji } from 'emojibase';
import { http, HttpResponse } from 'msw';
import { action } from 'storybook/actions';

import type { MediaAttachmentType } from '@/mastodon/api_types/media_attachments';
import { toSupportedLocale } from '@/mastodon/features/emoji/locale';

import {
  customEmojiFactory,
  mediaAttachmentFactoryAPI,
  relationshipsFactoryAPI,
} from './factories';

const mediaStorageMap = new Map<string, File>();

export const mockHandlers = {
  mute: http.post<{ id: string }>('/api/v1/accounts/:id/mute', ({ params }) => {
    action('muting account')(params);
    return HttpResponse.json(
      relationshipsFactoryAPI({ id: params.id, muting: true }),
    );
  }),
  unmute: http.post<{ id: string }>(
    '/api/v1/accounts/:id/unmute',
    ({ params }) => {
      action('unmuting account')(params);
      return HttpResponse.json(
        relationshipsFactoryAPI({ id: params.id, muting: false }),
      );
    },
  ),
  block: http.post<{ id: string }>(
    '/api/v1/accounts/:id/block',
    ({ params }) => {
      action('blocking account')(params);
      return HttpResponse.json(
        relationshipsFactoryAPI({ id: params.id, blocking: true }),
      );
    },
  ),
  unblock: http.post<{ id: string }>(
    '/api/v1/accounts/:id/unblock',
    ({ params }) => {
      action('unblocking account')(params);
      return HttpResponse.json(
        relationshipsFactoryAPI({
          id: params.id,
          blocking: false,
        }),
      );
    },
  ),
  mediaUpload: http.post('/api/v2/media', async ({ request }) => {
    action('uploaded media')();

    const formData = await request.formData();
    const file = formData.get('file');
    if (!file) {
      return new HttpResponse('Missing media', { status: 400 });
    }

    if (!(file instanceof File)) {
      return new HttpResponse('Media is not file', { status: 400 });
    }

    const { type: mimeType } = file;
    const id = mediaStorageMap.size.toString();
    mediaStorageMap.set(id, file);
    let type: MediaAttachmentType = 'unknown';
    if (mimeType === 'image/gif') {
      type = 'gifv';
    } else if (mimeType.startsWith('image/')) {
      type = 'image';
    } else if (mimeType.startsWith('video/')) {
      type = 'video';
    } else if (mimeType.startsWith('audio/')) {
      type = 'audio';
    }

    return HttpResponse.json(
      mediaAttachmentFactoryAPI({
        id,
        type,
        url: `/mock_media/${id}`,
        preview_url: `/mock_media/${id}`,
      }),
    );
  }),
  mediaGet: http.get<{ id: string }>('/mock_media/:id', async ({ params }) => {
    const { id } = params;
    action(`getting media id ${id}`)();

    const media = mediaStorageMap.get(id);
    if (!media) {
      return new HttpResponse('Not found', { status: 404 });
    }

    return HttpResponse.arrayBuffer(await media.arrayBuffer());
  }),
  emojiCustomData: http.get('/api/v1/custom_emojis', () => {
    action('fetching custom emoji data')();
    return HttpResponse.json([customEmojiFactory()]);
  }),
  emojiData: http.get<{ locale: string }>(
    '/packs-dev/emoji/:locale.json',
    async ({ params }) => {
      const locale = toSupportedLocale(params.locale);
      const key = `../../../../../node_modules/emojibase-data/${locale}/compact.json`;
      const emojiModules = import.meta.glob<CompactEmoji[]>(
        '../../../../../node_modules/emojibase-data/**/compact.json',
        { import: 'default' },
      );
      const path = emojiModules[key];
      if (!path) {
        throw new Error(`Unsupported locale: ${locale}`);
      }
      action('fetching emoji data')(locale);
      const data = await path();

      return HttpResponse.json([data]);
    },
  ),
};

export const unhandledRequestHandler = ({ url }: Request) => {
  const { pathname } = new URL(url);
  if (pathname.startsWith('/api/v1/')) {
    action(`unhandled request to ${pathname}`)(url);
    console.warn(
      `Unhandled request to ${pathname}. Please add a handler for this request in your storybook configuration.`,
    );
  }
};
