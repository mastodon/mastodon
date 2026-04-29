import type { FC } from 'react';
import { useEffect, useState } from 'react';

import type {
  CategoryName,
  CustomEmoji,
  EmojiProps,
  PickerProps,
} from 'emoji-mart';
import EmojiRaw from 'emoji-mart/dist-es/components/emoji/nimble-emoji';
import PickerRaw from 'emoji-mart/dist-es/components/picker/nimble-picker';

import { autoPlayGif } from '@/mastodon/initial_state';
import { assetHost } from 'mastodon/utils/config';

import { EMOJI_MODE_NATIVE } from './constants';
import EmojiData from './emoji_data.json';
import { useEmojiAppState } from './mode';
import { emojiLogger } from './utils';

const backgroundImageFnDefault = () => `${assetHost}/emoji/sheet_16_0.png`;

let customEmojis: CustomEmoji[] | null = null;
let customCategories = [
  'recent',
  'people',
  'nature',
  'foods',
  'activity',
  'places',
  'objects',
  'symbols',
  'flags',
] as CategoryName[];

const log = emojiLogger('picker');

export const Picker: FC<PickerProps> = ({
  backgroundImageFn = backgroundImageFnDefault,
  ...props
}) => {
  const { mode } = useEmojiAppState();
  const [isLoaded, setLoaded] = useState(customEmojis !== null);

  useEffect(() => {
    if (customEmojis === null) {
      void loadCustomEmojiData().then(() => {
        setLoaded(true);
      });
    }
  }, []);

  if (!isLoaded) {
    return null;
  }

  return (
    <PickerRaw
      set='twitter'
      sheetSize={32}
      sheetRows={62}
      sheetColumns={62}
      data={EmojiData}
      custom={customEmojis ?? []}
      include={customCategories}
      native={mode === EMOJI_MODE_NATIVE}
      backgroundImageFn={backgroundImageFn}
      {...props}
    />
  );
};

export async function loadCustomEmojiData() {
  const { loadAllCustomEmoji } = await import('./database');
  const emojisRaw = await loadAllCustomEmoji();
  if (emojisRaw.length === 0) {
    return;
  }

  const categories = new Set(['custom']);
  const emojis = [];
  for (const emoji of emojisRaw) {
    const name = emoji.shortcode.replaceAll(':', '');
    emojis.push({
      name,
      id: name,
      custom: true,
      short_names: [name],
      imageUrl: autoPlayGif ? emoji.url : emoji.static_url,
      customCategory: emoji.category,
    });

    if (emoji.category) {
      categories.add(`custom-${emoji.category}`);
    }
  }

  customEmojis = emojis.toSorted((a, b) => {
    return a.name.toLowerCase().localeCompare(b.name.toLowerCase());
  });
  customCategories = customCategories.toSpliced(
    1,
    0,
    ...(Array.from(categories).toSorted() as CategoryName[]),
  );
  log(
    'loaded %d custom emojis in %d categories',
    customEmojis.length,
    categories.size,
  );
}

export const Emoji: FC<EmojiProps> = ({
  backgroundImageFn = backgroundImageFnDefault,
  ...props
}) => {
  const { mode } = useEmojiAppState();
  return (
    <EmojiRaw
      set='twitter'
      sheetSize={32}
      sheetRows={62}
      sheetColumns={62}
      data={EmojiData}
      backgroundImageFn={backgroundImageFn}
      native={mode === EMOJI_MODE_NATIVE}
      {...props}
    />
  );
};
