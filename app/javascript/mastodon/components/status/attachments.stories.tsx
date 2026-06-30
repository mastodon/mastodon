import { List, Map } from 'immutable';

import type { Meta, StoryObj } from '@storybook/react-vite';

import {
  accountFactoryImmutable,
  cardFactoryAPI,
  collectionFactoryAPI,
  statusFactoryAPI,
  statusFactoryImmutable,
  statusQuotedFactoryAPI,
} from '@/testing/factories';

import { StatusAttachments } from './attachments';
import type { AttachmentArgs } from './testing';
import { attachmentArgTypes, attachmentFactory } from './testing';

interface StatusAttachmentsStoryProps extends AttachmentArgs {
  isFiltered: boolean;
  isSensitive: boolean;
  isPictureInPicture: boolean;
  isQuote: boolean;
}

const meta = {
  title: 'Components/Status/StatusAttachments',
  render() {
    return (
      <div style={{ width: 'min(600px, 80vw)' }}>
        <StatusAttachments statusId='1' contextType='home' />
      </div>
    );
  },
  args: {
    attachment1: 'image',
    attachment2: undefined,
    attachment3: undefined,
    isFiltered: false,
    isSensitive: false,
    isPictureInPicture: false,
    isQuote: false,
  },
  argTypes: {
    ...attachmentArgTypes,
    isFiltered: {
      control: 'boolean',
    },
    isSensitive: {
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
        '1': accountFactoryImmutable(),
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

      if (args.isSensitive) {
        status.sensitive = true;
      }

      if (args.isQuote) {
        status.quote = {
          state: 'accepted',
          quoted_status: statusQuotedFactoryAPI({ id: '2' }),
        };
      }

      if (args.attachment1 === 'card') {
        status.card = cardFactoryAPI({
          image:
            'https://images.pexels.com/photos/16859306/pexels-photo-16859306.jpeg',
        });
      } else if (args.attachment1 === 'collection') {
        status.tagged_collections = [collectionFactoryAPI()];
      } else if (args.attachment1) {
        status.media_attachments.push(
          ...attachmentFactory(
            args.attachment1,
            args.attachment2,
            args.attachment3,
          ),
        );
      }

      return {
        statuses: {
          '1': statusFactoryImmutable(status),
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
} as Meta<StatusAttachmentsStoryProps>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Image: Story = {};

export const Video: Story = {
  args: {
    attachment1: 'video',
  },
};

export const Audio: Story = {
  args: {
    attachment1: 'audio',
  },
};

export const Card: Story = {
  args: {
    attachment1: 'card',
  },
};

export const Collection: Story = {
  args: {
    attachment1: 'collection',
  },
};

export const Sensitive: Story = {
  args: {
    isSensitive: true,
  },
};

export const Filtered: Story = {
  args: {
    isFiltered: true,
  },
};

export const PictureInPicture: Story = {
  args: {
    attachment1: 'video',
    isPictureInPicture: true,
  },
};
