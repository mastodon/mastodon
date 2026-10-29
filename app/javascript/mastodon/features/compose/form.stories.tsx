import type { Meta, StoryObj } from '@storybook/react-vite';

import { ComposeForm } from './form';

const meta = {
  title: 'Redesign/Compose',
  component: ComposeForm,
  render() {
    return (
      <div style={{ width: 'max(40vw, 400px)' }}>
        <ComposeForm />
      </div>
    );
  },
  parameters: {
    redesign: true,
    state: {
      compose: {
        language: 'en',
      },
      media_attachments: {
        accept_content_types: [
          'image/jpeg',
          'image/png',
          'image/gif',
          'image/webp',
          'video/mp4',
          'video/quicktime',
          'video/ogg',
          'audio/wave',
          'audio/ogg',
          'audio/mp3',
        ],
      },
    },
  },
} satisfies Meta<typeof ComposeForm>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Post: Story = {};

export const PostPending: Story = {
  parameters: {
    state: {
      compose: {
        pending_media_attachments: 2,
      },
    },
  },
};

export const Reply: Story = {
  parameters: {
    state: {
      compose: {
        in_reply_to: '1',
      },
    },
  },
};

export const Message: Story = {
  parameters: {
    state: {
      compose: {
        privacy: 'direct',
      },
    },
  },
};
