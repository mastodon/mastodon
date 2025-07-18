import { useAppSelector } from '@/mastodon/store';

import { toSupportedLocale } from './locale';
import { determineEmojiMode } from './mode';
import type { EmojiAppState } from './types';

export function useEmojiAppState(): EmojiAppState {
  const locale = useAppSelector((state) =>
    toSupportedLocale(state.meta.get('locale') as string),
  );
  const mode = useAppSelector((state) =>
    determineEmojiMode(state.meta.get('emoji_style') as string),
  );

  return { currentLocale: locale, locales: [locale], mode };
}
