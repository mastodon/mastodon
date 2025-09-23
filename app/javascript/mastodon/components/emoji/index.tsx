import type { FC } from 'react';
import { useContext, useMemo } from 'react';

import {
  EMOJI_TYPE_UNICODE,
  EMOJI_TYPE_CUSTOM,
} from '@/mastodon/features/emoji/constants';
import { useEmojiAppState } from '@/mastodon/features/emoji/hooks';
import { emojiToUnicodeHex } from '@/mastodon/features/emoji/normalize';
import { shouldRenderUnicodeImage } from '@/mastodon/features/emoji/render';
import type {
  EmojiStateCustom,
  EmojiStateUnicode,
} from '@/mastodon/features/emoji/types';
import { anyEmojiRegex } from '@/mastodon/features/emoji/utils';

import { AnimateEmojiContext, CustomEmojiContext } from './context';

export const Emoji: FC<{ code: string; noFallback?: boolean }> = ({
  code: rawCode,
  noFallback,
}) => {
  const customEmoji = useContext(CustomEmojiContext);
  const appState = useEmojiAppState();
  const animate = useContext(AnimateEmojiContext);

  const state: null | Required<EmojiStateCustom> | EmojiStateUnicode =
    useMemo(() => {
      let code = rawCode;
      if (!anyEmojiRegex().test(code)) {
        return null;
      }
      if (code.startsWith(':') && code.endsWith(':')) {
        code = code.slice(1, -1); // Remove the colons
        const data = customEmoji[code];
        if (!data) {
          return null;
        }
        return {
          type: EMOJI_TYPE_CUSTOM,
          code,
          data,
        };
      }

      // If it's not custom, check if we should render this based on mode.
      if (!shouldRenderUnicodeImage(code, appState.mode)) {
        return null;
      }

      // If we are rendering it, convert it to a hex code.
      code = emojiToUnicodeHex(code);
      return {
        type: EMOJI_TYPE_UNICODE,
        code,
      };
    }, [appState.mode, customEmoji, rawCode]);

  if (!state) {
    return noFallback ? null : rawCode;
  }

  if (state.type === EMOJI_TYPE_CUSTOM) {
    return (
      <img
        src={animate ? state.data.url : state.data.static_url}
        alt={state.code}
        className='emoji'
      />
    );
  }

  // TODO: Load data
  if (!state.data) {
    return null;
  }

  return (
    <img
      src={`/emoji/${state.code}.svg`}
      alt={state.data.label}
      className='emoji'
    />
  );
};
