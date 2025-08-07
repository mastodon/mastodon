import { useCallback, useLayoutEffect, useMemo, useState } from 'react';

import { isList } from 'immutable';

import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';
import { useAppSelector } from '@/mastodon/store';
import { isModernEmojiEnabled } from '@/mastodon/utils/environment';

import { toSupportedLocale } from './locale';
import { determineEmojiMode } from './mode';
import type {
  CustomEmojiMapArg,
  EmojiAppState,
  ExtraCustomEmojiMap,
} from './types';
import { stringHasAnyEmoji } from './utils';

export function useEmojify(text: string, extraEmojis?: CustomEmojiMapArg) {
  const [emojifiedText, setEmojifiedText] = useState<string | null>(null);

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
    async (input: string) => {
      const wrapper = document.createElement('div');
      wrapper.innerHTML = input;
      const { emojifyElement } = await import('./render');
      const result = await emojifyElement(wrapper, appState, extra);
      if (result) {
        setEmojifiedText(result.innerHTML);
      } else {
        setEmojifiedText(input);
      }
    },
    [appState, extra],
  );
  useLayoutEffect(() => {
    if (isModernEmojiEnabled() && !!text.trim() && stringHasAnyEmoji(text)) {
      void emojify(text);
    } else {
      // If no emoji or we don't want to render, fall back.
      setEmojifiedText(text);
    }
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
