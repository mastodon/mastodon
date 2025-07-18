import { useEffect, useState } from 'react';

import { isFeatureEnabled } from '@/mastodon/initial_state';

import emojify from './emoji';
import { useEmojiAppState } from './hooks';
import { emojifyElement } from './render';

interface EmojiHTMLProps {
  htmlString: string;
}

export const EmojiHTML: React.FC<EmojiHTMLProps> = ({ htmlString: text }) => {
  const appState = useEmojiAppState();
  const [innerHTML, setInnerHTML] = useState('');

  useEffect(() => {
    const cb = async () => {
      const div = document.createElement('div');
      div.innerHTML = text;
      const ele = await emojifyElement(div, appState);
      setInnerHTML(ele.innerHTML);
    };
    if (isFeatureEnabled('modern_emojis')) {
      void cb();
    } else {
      setInnerHTML(emojify(text));
    }
  }, [text, appState]);

  if (!innerHTML) {
    return null;
  }

  return <div dangerouslySetInnerHTML={{ __html: innerHTML }} />;
};
