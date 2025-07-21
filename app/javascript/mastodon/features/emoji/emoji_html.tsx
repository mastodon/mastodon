import type { HTMLAttributes } from 'react';
import { useEffect, useMemo, useState } from 'react';

import type { List as ImmutableList } from 'immutable';
import { isList } from 'immutable';

import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';
import { isFeatureEnabled } from '@/mastodon/initial_state';
import type { CustomEmoji } from '@/mastodon/models/custom_emoji';

import { useEmojiAppState } from './hooks';
import { emojifyElement } from './render';
import type { ExtraCustomEmojiMap } from './types';

interface EmojiHTMLProps {
  htmlString: string;
  extraEmojis?: ExtraCustomEmojiMap | ImmutableList<CustomEmoji>;
}

export const EmojiHTML: React.FC<
  EmojiHTMLProps &
    Omit<HTMLAttributes<HTMLDivElement>, 'dangerouslySetInnerHTML'>
> = ({ extraEmojis: rawEmojis, htmlString: text, ...props }) => {
  const appState = useEmojiAppState();
  const [innerHTML, setInnerHTML] = useState('');

  const extraEmojis: ExtraCustomEmojiMap = useMemo(() => {
    if (!rawEmojis) {
      return {};
    }
    if (isList(rawEmojis)) {
      return (
        rawEmojis.toJS() as ApiCustomEmojiJSON[]
      ).reduce<ExtraCustomEmojiMap>(
        (acc, emoji) => ({ ...acc, [emoji.shortcode]: emoji }),
        {},
      );
    }
    return rawEmojis;
  }, [rawEmojis]);

  useEffect(() => {
    if (!text) {
      return;
    }
    const cb = async () => {
      const div = document.createElement('div');
      div.innerHTML = text;
      const ele = await emojifyElement(div, appState, extraEmojis);
      setInnerHTML(ele.innerHTML);
    };
    if (isFeatureEnabled('modern_emojis')) {
      void cb();
    } else {
      setInnerHTML(text); // Assume the text is already emojified
    }
  }, [text, appState, extraEmojis]);

  if (!innerHTML) {
    return null;
  }

  return <div {...props} dangerouslySetInnerHTML={{ __html: innerHTML }} />;
};
