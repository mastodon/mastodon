import { List, Map } from 'immutable';

import type { Meta, StoryObj } from '@storybook/react-vite';

import type { MediaAttachmentType } from '@/mastodon/api_types/media_attachments';
import {
  accountFactoryState,
  cardFactoryAPI,
  collectionFactoryAPI,
  mediaAttachmentFactoryAPI,
  statusFactoryAPI,
  statusFactoryState,
  statusQuotedFactoryAPI,
} from '@/testing/factories';

import { StatusAttachments } from './attachments';

type AttachmentType = MediaAttachmentType | 'collection' | 'card';
type ExtraAttachmentType = Exclude<MediaAttachmentType, 'video' | 'audio'>;

interface StatusAttachmentsStoryProps {
  attachment1?: AttachmentType;
  attachment2?: ExtraAttachmentType;
  attachment3?: ExtraAttachmentType;
  isFiltered: boolean;
  isPictureInPicture: boolean;
  isQuote: boolean;
}

const meta = {
  title: 'Components/Status/StatusAttachments',
  render() {
    return (
      <div style={{ width: 'min(600px, 80vw)' }}>
        <StatusAttachments statusId='1' contextType='home' />;
      </div>
    );
  },
  args: {
    attachment1: 'image',
    attachment2: 'image',
    attachment3: 'image',
    isFiltered: false,
    isPictureInPicture: false,
    isQuote: false,
  },
  argTypes: {
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
      ] satisfies AttachmentType[],
    },
    attachment2: {
      control: 'select',
      options: ['image', 'gifv', 'unknown'] satisfies AttachmentType[],
    },
    attachment3: {
      control: 'select',
      options: ['image', 'gifv', 'unknown'] satisfies AttachmentType[],
    },
    isFiltered: {
      control: 'boolean',
    },
    isPictureInPicture: {
      control: 'boolean',
    },
    isQuote: {
      control: 'boolean',
    },
  },
  parameters: {
    state: {
      filters: {
        '1': Map({
          id: '1',
          title: 'Test',
          context: List(['home']),
          expires_at: null,
          filter_action: 'blur',
        }),
      },
      accounts: {
        '1': accountFactoryState(),
      },
      server: {
        translationLanguages: {
          item: {
            xx: ['en', 'de', 'fr'],
          },
        },
      },
    },
    stateFn(args: StatusAttachmentsStoryProps) {
      const status = statusFactoryAPI();

      if (args.isFiltered) {
        status.filtered = [
          {
            filter: {
              id: '1',
              title: 'Test',
              context: 'home',
              expires_at: '',
              filter_action: 'warn',
            },
            keyword_matches: [],
            status_matches: [],
          },
        ];
      }

      if (args.isQuote) {
        status.quote = {
          state: 'accepted',
          quoted_status: statusQuotedFactoryAPI({ id: '2' }),
        };
      }

      if (args.attachment1 === 'card') {
        status.card = cardFactoryAPI();
      } else if (args.attachment1 === 'collection') {
        status.tagged_collections = [collectionFactoryAPI()];
      } else if (args.attachment1 === 'audio') {
        status.media_attachments.push(
          mediaAttachmentFactoryAPI({
            type: 'audio',
            url: 'https://upload.wikimedia.org/wikipedia/commons/4/40/Elephant_voice_-_trumpeting.ogg',
            preview_url:
              'https://images.pexels.com/photos/16859306/pexels-photo-16859306.jpeg',
          }),
        );
      } else if (args.attachment1 === 'video') {
        status.media_attachments.push(
          mediaAttachmentFactoryAPI({
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
          }),
        );
      } else if (args.attachment1) {
        status.media_attachments.push(extraAttachmentType(args.attachment1));
        if (args.attachment2) {
          status.media_attachments.push(
            extraAttachmentType(args.attachment2, '2'),
          );
        }

        if (args.attachment3) {
          status.media_attachments.push(
            extraAttachmentType(args.attachment3, '3'),
          );
        }
      }

      return {
        statuses: {
          '1': statusFactoryState(status),
        },
        picture_in_picture: args.isPictureInPicture
          ? {
              statusId: '1',
              accountId: '1',
              type: args.attachment1 === 'audio' ? 'audio' : 'video',
            }
          : undefined,
      };
    },
  },
} satisfies Meta<StatusAttachmentsStoryProps>;

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

function extraAttachmentType(
  type: ExtraAttachmentType,
  id: '1' | '2' | '3' = '1',
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

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};
