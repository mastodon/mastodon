import type { FC, ReactNode } from 'react';
import { useMemo } from 'react';

import { createLimitedCache } from '@/mastodon/utils/cache';

import emojify from '../../features/emoji/emoji';
import { htmlStringToComponents } from '../../utils/html';

// Use a module-level cache to avoid re-rendering the same HTML multiple times.
const cache = createLimitedCache<ReactNode>({ maxSize: 1000 });

export const HTMLBlock: FC<{
  contents: string;
}> = ({ contents: raw }) => {
  const contents = useMemo(() => {
    if (cache.has(raw)) {
      return cache.get(raw);
    }
    const rendered = htmlStringToComponents(raw, {
      onText,
    });
    cache.set(raw, rendered);
    return rendered;
  }, [raw]);

  return contents;
};

function onText(text: string) {
  return emojify(text);
}
