import { useCallback, useLayoutEffect, useMemo, useState } from 'react';

import { isList } from 'immutable';

import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';
import { useAppSelector } from '@/mastodon/store';
import { isModernEmojiEnabled } from '@/mastodon/utils/environment';

import { toSupportedLocale } from './locale';
import { determineEmojiMode } from './mode';
import { emojifyElement, emojifyText } from './render';
import type {
  CustomEmojiMapArg,
  EmojiAppState,
  ExtraCustomEmojiMap,
} from './types';

interface UseEmojifyOptions {
  text: string;
  extraEmojis?: CustomEmojiMapArg;
  deep?: boolean;
}

export function useEmojify({
  text,
  extraEmojis,
  deep = true,
}: UseEmojifyOptions) {
  const [emojifiedText, setEmojifiedText] = useState(text);

  const appState = useEmojiAppState();
  const extra: ExtraCustomEmojiMap = useMemo(() => {
    if (!extraEmojis) {
      return {};
    }
    if (isList(extraEmojis)) {
      return (
        extraEmojis.toJS() as ApiCustomEmojiJSON[]
      ).reduce<ExtraCustomEmojiMap>(
        (acc, emoji) => ({ ...acc, [emoji.shortcode]: emoji }),
        {},
      );
    }
    return extraEmojis;
  }, [extraEmojis]);

  const emojify = useCallback(
    (input: string) => {
      if (!deep) {
        return emojifyText(input, appState, extra);
      }
      const wrapper = document.createElement('div');
      wrapper.innerHTML = input;
      return emojifyElement(wrapper, appState, extra);
    },
    [appState, deep, extra],
  );

  useLayoutEffect(() => {
    if (isModernEmojiEnabled() && !!text.trim()) {
      const result = emojify(text);
      const newText = result instanceof HTMLElement ? result.innerHTML : result;
      if (newText) {
        setEmojifiedText(newText);
        return;
      }
    }
    // If no emoji or we don't want to render, fall back.
    setEmojifiedText(text);
  }, [emojify, text]);

  return emojifiedText;
}

export function useEmojiAppState(): EmojiAppState {
  const locale = useAppSelector((state) =>
    toSupportedLocale(state.meta.get('locale') as string),
  );
  const mode = useAppSelector((state) =>
    determineEmojiMode(state.meta.get('emoji_style') as string),
  );

  return {
    currentLocale: locale,
    locales: [locale],
    mode,
    darkTheme: document.body.classList.contains('theme-default'),
  };
}
