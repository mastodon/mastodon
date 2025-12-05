import type { FC } from 'react';
import { useContext, useEffect, useState } from 'react';

import classNames from 'classnames';

import { EMOJI_TYPE_CUSTOM } from '@/mastodon/features/emoji/constants';
import { useEmojiAppState } from '@/mastodon/features/emoji/mode';
import {
  emojiToInversionClassName,
  unicodeHexToUrl,
} from '@/mastodon/features/emoji/normalize';
import {
  isStateLoaded,
  loadEmojiDataToState,
  shouldRenderImage,
  stringToEmojiState,
  tokenizeText,
} from '@/mastodon/features/emoji/render';

import { AnimateEmojiContext, CustomEmojiContext } from './context';

interface EmojiProps {
  code: string;
  showFallback?: boolean;
  showLoading?: boolean;
}

export const Emoji: FC<EmojiProps> = ({
  code,
  showFallback = true,
  showLoading = true,
}) => {
  const customEmoji = useContext(CustomEmojiContext);

  // First, set the emoji state based on the input code.
  const [state, setState] = useState(() =>
    stringToEmojiState(code, customEmoji),
  );

  // If we don't have data, then load emoji data asynchronously.
  const appState = useEmojiAppState();
  useEffect(() => {
    if (state !== null) {
      void loadEmojiDataToState(state, appState.currentLocale).then(setState);
    }
  }, [appState.currentLocale, state]);

  const animate = useContext(AnimateEmojiContext);

  const inversionClass = emojiToInversionClassName(code);

  const fallback = showFallback ? code : null;

  // If the code is invalid or we otherwise know it's not valid, show the fallback.
  if (!state) {
    return fallback;
  }

  if (!shouldRenderImage(state, appState.mode)) {
    return code;
  }

  if (!isStateLoaded(state)) {
    if (showLoading) {
      return <span className='emojione emoji-loading' title={code} />;
    }
    return fallback;
  }

  if (state.type === EMOJI_TYPE_CUSTOM) {
    const shortcode = `:${state.code}:`;
    return (
      <img
        src={animate ? state.data.url : state.data.static_url}
        alt={shortcode}
        title={shortcode}
        className='emojione custom-emoji'
        loading='lazy'
      />
    );
  }

  const src = unicodeHexToUrl(state.code, appState.darkTheme);

  return (
    <img
      src={src}
      alt={state.data.unicode}
      title={state.data.label}
      className={classNames('emojione', inversionClass)}
      loading='lazy'
    />
  );
};

/**
 * Takes a text string and converts it to an array of React nodes.
 * @param text The text to be tokenized and converted.
 */
export function textToEmojis(text: string) {
  return tokenizeText(text).map((token, index) => {
    if (typeof token === 'string') {
      return token;
    }
    return <Emoji code={token.code} key={`emoji-${token.code}-${index}`} />;
  });
}
