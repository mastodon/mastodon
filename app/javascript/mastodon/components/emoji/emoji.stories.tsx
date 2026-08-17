import type { ComponentProps } from 'react';

import type { Meta, StoryObj } from '@storybook/react-vite';

import { customEmojiFactory } from '@/testing/factories';

import { CustomEmojiProvider } from './context';
import { Emoji } from './index';

type EmojiProps = ComponentProps<typeof Emoji> & {
  style: 'auto' | 'native' | 'twemoji';
};

const meta = {
  title: 'Components/Emoji',
  component: Emoji,
  args: {
    code: '🖤',
    style: 'auto',
  },
  argTypes: {
    code: {
      name: 'Emoji',
    },
    style: {
      control: {
        type: 'select',
        labels: {
          auto: 'Auto',
          native: 'Native',
          twemoji: 'Twemoji',
        },
      },
      options: ['auto', 'native', 'twemoji'],
      name: 'Emoji Style',
      reduxPath: 'meta.emoji_style',
    },
  },
  render(args) {
    return (
      <CustomEmojiProvider emojis={[customEmojiFactory()]}>
        <Emoji {...args} />
      </CustomEmojiProvider>
    );
  },
} satisfies Meta<EmojiProps>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};

export const CustomEmoji: Story = {
  args: {
    code: ':custom:',
  },
};
