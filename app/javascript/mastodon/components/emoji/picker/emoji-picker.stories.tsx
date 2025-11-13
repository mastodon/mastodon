import type { Meta, StoryObj } from '@storybook/react-vite';
import { action } from 'storybook/actions';

import {
  importCustomEmojiData,
  importEmojiData,
} from '@/mastodon/features/emoji/loader';

import { MockEmojiPicker } from './index';

const onSelect = action('emoji selected');

const meta = {
  title: 'Components/Emoji/EmojiPicker',
  render(_args, { globals }) {
    const locale = typeof globals.locale === 'string' ? globals.locale : 'en';

    void importCustomEmojiData();
    void importEmojiData(locale);
    return <MockEmojiPicker onSelect={onSelect} />;
  },
} satisfies Meta;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};
