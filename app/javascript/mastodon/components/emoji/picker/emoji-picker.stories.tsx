import type { FC } from 'react';
import { useState } from 'react';

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
    return <StoryComponent locale={locale} />;
  },
} satisfies Meta;

const StoryComponent: FC<{ locale: string }> = ({ locale }) => {
  const [loaded, setLoaded] = useState(false);

  void Promise.all([importCustomEmojiData(), importEmojiData(locale)]).then(
    () => {
      setLoaded(true);
    },
  );

  if (!loaded) {
    return null;
  }
  return <MockEmojiPicker onSelect={onSelect} />;
};

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};
