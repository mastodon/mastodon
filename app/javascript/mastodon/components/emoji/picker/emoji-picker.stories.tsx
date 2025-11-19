import type { FC } from 'react';
import { useState } from 'react';

import type { Meta, StoryObj } from '@storybook/react-vite';
import type { CompactEmoji } from 'emojibase';
import { flattenEmojiData } from 'emojibase';
import { action } from 'storybook/actions';

import { putEmojiData } from '@/mastodon/features/emoji/database';
import { toSupportedLocale } from '@/mastodon/features/emoji/locale';

import { MockEmojiPicker } from './index';

const onSelect = action('emoji selected');
const onSkinToneChange = action('skin tone changed');

const meta = {
  title: 'Components/Emoji/EmojiPicker',
  render(_args, { globals }) {
    const locale = typeof globals.locale === 'string' ? globals.locale : 'en';
    return <StoryComponent locale={locale} key={locale} />;
  },
} satisfies Meta;

const StoryComponent: FC<{ locale: string }> = ({ locale }) => {
  const [loaded, setLoaded] = useState(false);

  if (!loaded) {
    void loadEmojiData(locale).then(() => {
      action('emoji data loaded')(locale);
      setLoaded(true);
    });
  }

  if (!loaded) {
    return null;
  }
  return (
    <MockEmojiPicker onSelect={onSelect} onSkinToneChange={onSkinToneChange} />
  );
};

async function loadEmojiData(localeString: string) {
  const locale = toSupportedLocale(localeString);
  const emojis = (await import(
    `../../../../../../node_modules/emojibase-data/${locale}/compact.json`
  )) as { default: CompactEmoji[] };
  const flattenedEmojis = flattenEmojiData(emojis.default);
  await putEmojiData(flattenedEmojis, locale);
}

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};
