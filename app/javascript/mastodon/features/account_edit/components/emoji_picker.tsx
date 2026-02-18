import { useCallback } from 'react';
import type { FC } from 'react';

import { isPlainObject } from '@reduxjs/toolkit';

import EmojiPickerDropdown from '../../compose/containers/emoji_picker_dropdown_container';

export const EmojiPicker: FC<{ onPick: (emoji: string) => void }> = ({
  onPick,
}) => {
  const handlePick = useCallback(
    (emoji: unknown) => {
      if (isPlainObject(emoji)) {
        if ('native' in emoji && typeof emoji.native === 'string') {
          onPick(emoji.native);
        } else if (
          'shortcode' in emoji &&
          typeof emoji.shortcode === 'string'
        ) {
          onPick(`:${emoji.shortcode}:`);
        }
      }
    },
    [onPick],
  );
  return <EmojiPickerDropdown onPickEmoji={handlePick} />;
};
