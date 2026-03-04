import { useCallback } from 'react';
import type { FC } from 'react';

import EmojiPickerDropdown from '@/flavours/glitch/features/compose/containers/emoji_picker_dropdown_container';

export const EmojiPickerButton: FC<{
  onPick: (emoji: string) => void;
  disabled?: boolean;
}> = ({ onPick, disabled }) => {
  const handlePick = useCallback(
    (emoji: unknown) => {
      if (disabled) {
        return;
      }
      if (typeof emoji === 'object' && emoji !== null) {
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
    [disabled, onPick],
  );
  return <EmojiPickerDropdown onPickEmoji={handlePick} disabled={disabled} />;
};
