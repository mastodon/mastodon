import type { FC } from 'react';

import type { EmojiProps, PickerProps } from 'emoji-mart';
import EmojiRaw from 'emoji-mart/dist-es/components/emoji/nimble-emoji';
import PickerRaw from 'emoji-mart/dist-es/components/picker/nimble-picker';

import { assetHost } from '@/mastodon/utils/config';

import { EMOJI_MODE_NATIVE } from './constants';
import EmojiData from './emoji_data.json';
import { useEmojiAppState } from './mode';
import { usePickerEmojis } from './picker';

const backgroundImageFnDefault = () => `${assetHost}/emoji/sheet_16_0.png`;

export { fetchCustomEmojiData as loadCustomEmojiData } from './picker';

export const Picker: FC<PickerProps> = ({
  set = 'twitter',
  sheetSize = 32,
  sheetColumns = 62,
  sheetRows = 62,
  backgroundImageFn = backgroundImageFnDefault,
  ...props
}) => {
  const { mode } = useEmojiAppState();
  const { customCategories, customEmojis } = usePickerEmojis();

  if (!customEmojis) {
    return null;
  }

  return (
    <PickerRaw
      data={EmojiData}
      custom={customEmojis}
      include={customCategories}
      set={set}
      sheetSize={sheetSize}
      sheetColumns={sheetColumns}
      sheetRows={sheetRows}
      native={mode === EMOJI_MODE_NATIVE}
      backgroundImageFn={backgroundImageFn}
      {...props}
    />
  );
};

export const Emoji: FC<EmojiProps> = ({
  set = 'twitter',
  sheetSize = 32,
  sheetColumns = 62,
  sheetRows = 62,
  backgroundImageFn = backgroundImageFnDefault,
  ...props
}) => {
  const { mode } = useEmojiAppState();
  return (
    <EmojiRaw
      data={EmojiData}
      set={set}
      sheetSize={sheetSize}
      sheetColumns={sheetColumns}
      sheetRows={sheetRows}
      backgroundImageFn={backgroundImageFn}
      native={mode === EMOJI_MODE_NATIVE}
      {...props}
    />
  );
};
