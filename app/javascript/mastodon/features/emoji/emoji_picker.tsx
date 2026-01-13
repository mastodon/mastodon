import type { EmojiProps, PickerProps } from 'emoji-mart';
import EmojiRaw from 'emoji-mart/dist-es/components/emoji/nimble-emoji';
import PickerRaw from 'emoji-mart/dist-es/components/picker/nimble-picker';

import { assetHost } from 'mastodon/utils/config';

import { EMOJI_MODE_NATIVE } from './constants';
import EmojiData from './emoji_data.json';
import { useEmojiAppState } from './mode';

const backgroundImageFnDefault = () => `${assetHost}/emoji/sheet_16_0.png`;

const Emoji = ({
  set = 'twitter',
  sheetSize = 32,
  sheetColumns = 62,
  sheetRows = 62,
  backgroundImageFn = backgroundImageFnDefault,
  ...props
}: EmojiProps) => {
  const { mode } = useEmojiAppState();
  return (
    <EmojiRaw
      data={EmojiData}
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

const Picker = ({
  set = 'twitter',
  sheetSize = 32,
  sheetColumns = 62,
  sheetRows = 62,
  backgroundImageFn = backgroundImageFnDefault,
  ...props
}: PickerProps) => {
  const { mode } = useEmojiAppState();
  return (
    <PickerRaw
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

export { Picker, Emoji };
