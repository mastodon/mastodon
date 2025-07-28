import { useCallback, useEffect, useMemo, useState } from 'react';

import { isList } from 'immutable';

import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';
import { useAppSelector } from '@/mastodon/store';
import { isModernEmojiEnabled } from '@/mastodon/utils/environment';

import { toSupportedLocale } from './locale';
import { determineEmojiMode } from './mode';
import { emojifyElement } from './render';
import type {
  CustomEmojiMapArg,
  EmojiAppState,
  ExtraCustomEmojiMap,
} from './types';
import { stringHasAnyEmoji } from './utils';

export function useEmojify(text: string, extraEmojis?: CustomEmojiMapArg) {
  const hasEmoji = useHasEmoji(text);
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
  const [innerHTML, setInnerHTML] = useState<string | null>(null);

  const emojify = useCallback(
    async (input: string) => {
      const div = document.createElement('div');
      div.innerHTML = input;
      const ele = await emojifyElement(div, appState, extra);
      setInnerHTML(ele.innerHTML);
    },
    [appState, extra],
  );
  useEffect(() => {
    if (hasEmoji) {
      void emojify(text);
    }
  }, [emojify, hasEmoji, text]);

  return innerHTML;
}

export function useHasEmoji(text: string): boolean {
  return useMemo(
    () => isModernEmojiEnabled() && !!text.trim() && stringHasAnyEmoji(text),
    [text],
  );
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
