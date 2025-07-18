import { useEffect, useState } from 'react';

import { isFeatureEnabled } from '@/mastodon/initial_state';

import emojify from './emoji';
import { useEmojiAppState } from './hooks';
import { emojifyElement } from './render';
import type { ExtraCustomEmojiMap } from './types';

interface EmojiHTMLProps {
  htmlString: string;
  extraEmojis?: ExtraCustomEmojiMap;
}

export const EmojiHTML: React.FC<EmojiHTMLProps> = ({
  htmlString: text,
  extraEmojis = {},
}) => {
  const appState = useEmojiAppState();
  const [innerHTML, setInnerHTML] = useState('');

  useEffect(() => {
    const cb = async () => {
      const div = document.createElement('div');
      div.innerHTML = text;
      const ele = await emojifyElement(div, appState, extraEmojis);
      setInnerHTML(ele.innerHTML);
    };
    if (isFeatureEnabled('modern_emojis')) {
      void cb();
    } else {
      setInnerHTML(emojify(text));
    }
  }, [text, appState, extraEmojis]);

  if (!innerHTML) {
    return null;
  }

  return <div dangerouslySetInnerHTML={{ __html: innerHTML }} />;
};
