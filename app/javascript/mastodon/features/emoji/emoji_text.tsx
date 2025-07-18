import { useEffect, useState } from 'react';

import { useEmojiAppState } from './hooks';
import { emojifyText } from './render';

interface EmojiTextProps {
  text: string;
}

export const EmojiText: React.FC<EmojiTextProps> = ({ text }) => {
  const appState = useEmojiAppState();
  const [rendered, setRendered] = useState<(string | HTMLImageElement)[]>([]);

  useEffect(() => {
    const cb = async () => {
      const rendered = await emojifyText(text, appState);
      setRendered(rendered ?? []);
    };
    void cb();
  }, [text, appState]);

  if (rendered.length === 0) {
    return null;
  }

  return (
    <>
      {rendered.map((fragment, index) => {
        if (typeof fragment === 'string') {
          return <span key={index}>{fragment}</span>;
        }
        return (
          <img
            key={index}
            draggable='false'
            src={fragment.src}
            alt={fragment.alt}
            title={fragment.title}
            className={fragment.className}
          />
        );
      })}
    </>
  );
};
