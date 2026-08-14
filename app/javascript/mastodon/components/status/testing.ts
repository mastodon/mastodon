import type { ArgTypes } from '@storybook/react-vite';

import type { MediaAttachmentType } from '@/mastodon/api_types/media_attachments';
import { mediaAttachmentFactoryAPI } from '@/testing/factories';

export type MainAttachmentType = MediaAttachmentType | 'collection' | 'card';
export type ExtraAttachmentType = Exclude<
  MediaAttachmentType,
  'video' | 'audio'
>;

export interface AttachmentArgs {
  attachment1?: MainAttachmentType;
  attachment2?: ExtraAttachmentType;
  attachment3?: ExtraAttachmentType;
}

export const attachmentArgTypes = {
  attachment1: {
    control: 'select',
    options: [
      'image',
      'gifv',
      'video',
      'unknown',
      'audio',
      'collection',
      'card',
    ] satisfies MainAttachmentType[],
  },
  attachment2: {
    control: 'select',
    options: ['image', 'gifv', 'unknown'] satisfies ExtraAttachmentType[],
  },
  attachment3: {
    control: 'select',
    options: ['image', 'gifv', 'unknown'] satisfies ExtraAttachmentType[],
  },
} as const satisfies ArgTypes<AttachmentArgs>;

export function attachmentFactory(
  attachment1?: MainAttachmentType,
  attachment2?: ExtraAttachmentType,
  attachment3?: ExtraAttachmentType,
) {
  if (!attachment1 || attachment1 === 'card' || attachment1 === 'collection') {
    return [];
  }

  const attachments = [mainMediaAttachmentFactory(attachment1)];
  if (attachment2) {
    attachments.push(extraAttachmentFactory(attachment2, '2'));
  }
  if (attachment3) {
    attachments.push(extraAttachmentFactory(attachment3, '3'));
  }
  return attachments;
}

export function mainMediaAttachmentFactory(type: MediaAttachmentType) {
  if (type === 'video') {
    return mediaAttachmentFactoryAPI({
      type: 'video',
      url: 'https://www.pexels.com/download/video/11760787/',
      preview_url:
        'https://images.pexels.com/photos/16859306/pexels-photo-16859306.jpeg',
      meta: {
        original: {
          width: 2160,
          height: 4096,
        },
      },
    });
  }

  if (type === 'audio') {
    return mediaAttachmentFactoryAPI({
      type: 'audio',
      url: 'https://upload.wikimedia.org/wikipedia/commons/4/40/Elephant_voice_-_trumpeting.ogg',
      preview_url:
        'https://images.pexels.com/photos/16859306/pexels-photo-16859306.jpeg',
    });
  }

  return extraAttachmentFactory(type, '1');
}

type MediaData = Record<
  '1' | '2' | '3',
  { url: string; width: number; height: number }
>;

const imageIdToData = {
  '1': {
    url: 'https://cataas.com/cat/bYBTjiFUqjUPIBUD',
    width: 1280,
    height: 964,
  },
  '2': {
    url: 'https://cataas.com/cat/YFaQ4xWYoWURSz37',
    width: 964,
    height: 1280,
  },
  '3': {
    url: 'https://cataas.com/cat/EbVq9zMc4Xxv7s73',
    width: 960,
    height: 1280,
  },
} satisfies MediaData;
const gifIdToData = {
  '1': {
    url: 'https://www.pexels.com/download/video/11760787/',
    width: 2160,
    height: 4096,
  },
  '2': {
    url: 'https://www.pexels.com/download/video/19787248/',
    width: 3840,
    height: 2160,
  },
  '3': {
    url: 'https://www.pexels.com/download/video/37411294/',
    width: 3840,
    height: 2160,
  },
} satisfies MediaData;

export function extraAttachmentFactory(
  type: ExtraAttachmentType,
  id: '1' | '2' | '3',
) {
  const metaData = type === 'image' ? imageIdToData[id] : gifIdToData[id];
  switch (type) {
    case 'image':
      return mediaAttachmentFactoryAPI({
        id,
        type: 'image',
        url: metaData.url,
        meta: {
          original: {
            width: metaData.width,
            height: metaData.height,
            size: `${metaData.width}x${metaData.height}`,
            aspect: metaData.width / metaData.height,
          },
        },
      });
    case 'gifv':
      return mediaAttachmentFactoryAPI({
        id,
        type: 'gifv',
        url: metaData.url,
        meta: {
          original: {
            width: metaData.width,
            height: metaData.height,
          },
        },
      });
    case 'unknown':
      return mediaAttachmentFactoryAPI({ id, type: 'unknown' });
  }
}
