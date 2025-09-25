import type { FC, ReactNode } from 'react';
import { useMemo } from 'react';

import { cleanExtraEmojis } from '@/mastodon/features/emoji/normalize';
import type { CustomEmojiMapArg } from '@/mastodon/features/emoji/types';
import { createLimitedCache } from '@/mastodon/utils/cache';

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
  // eslint-disable-next-line @typescript-eslint/no-unused-vars -- Doesn't do anything, just showing how typing would work.
  { customEmojis }: { customEmojis: CustomEmojiMapArg | null },
) {
  return text;
}
