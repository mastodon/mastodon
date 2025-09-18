import type { FC, ReactNode } from 'react';
import { useMemo } from 'react';

import { cleanExtraEmojis } from '@/mastodon/features/emoji/normalize';
import type { CustomEmojiMapArg } from '@/mastodon/features/emoji/types';
import { createLimitedCache } from '@/mastodon/utils/cache';

import emojify from '../../features/emoji/emoji';
import { htmlStringToComponents } from '../../utils/html';

// Use a module-level cache to avoid re-rendering the same HTML multiple times.
const cache = createLimitedCache<ReactNode>({ maxSize: 1000 });

interface HTMLBlockProps {
  contents: string;
  extraEmojis?: CustomEmojiMapArg;
}

export const HTMLBlock: FC<HTMLBlockProps> = ({
  contents: raw,
  extraEmojis,
}) => {
  const customEmojis = useMemo(
    () => cleanExtraEmojis(extraEmojis),
    [extraEmojis],
  );
  const contents = useMemo(() => {
    const key = JSON.stringify({ raw, customEmojis });
    if (cache.has(key)) {
      return cache.get(key);
    }
    const rendered = htmlStringToComponents(raw, {
      onText,
      extraArgs: { customEmojis },
    });

    cache.set(key, rendered);
    return rendered;
  }, [raw, customEmojis]);

  return contents;
};

function onText(
  text: string,
  { customEmojis }: { customEmojis: CustomEmojiMapArg },
) {
  const result = emojify(text, customEmojis);
  const components = htmlStringToComponents(result);

  // TODO: Wire up new emoji rendering when it's sync.
  return components;
}
