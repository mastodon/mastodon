import type { Meta, StoryObj } from '@storybook/react-vite';

import {
  importCustomEmojiData,
  importEmojiData,
} from '@/mastodon/features/emoji/loader';

import { MockEmojiPicker } from './index';

const meta = {
  title: 'Components/Emoji/EmojiPicker',
  render() {
    void importCustomEmojiData();
    void importEmojiData('en');
    return <MockEmojiPicker />;
  },
} satisfies Meta<typeof MockEmojiPicker>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};
