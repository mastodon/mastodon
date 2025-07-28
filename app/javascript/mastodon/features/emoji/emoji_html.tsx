import type { HTMLAttributes } from 'react';

import { useEmojify, useHasEmoji } from './hooks';
import type { CustomEmojiMapArg } from './types';

type EmojiHTMLProps = Omit<
  HTMLAttributes<HTMLDivElement>,
  'dangerouslySetInnerHTML'
> & {
  htmlString: string;
  extraEmojis?: CustomEmojiMapArg;
};

export const EmojiHTML: React.FC<EmojiHTMLProps> = ({
  htmlString,
  extraEmojis,
  ...props
}) => {
  const hasEmoji = useHasEmoji(htmlString);
  if (hasEmoji) {
    return (
      <ModernEmojiHTML
        htmlString={htmlString}
        extraEmojis={extraEmojis}
        {...props}
      />
    );
  }
  return <div {...props} dangerouslySetInnerHTML={{ __html: htmlString }} />;
};

const ModernEmojiHTML: React.FC<EmojiHTMLProps> = ({
  extraEmojis,
  htmlString,
  ...props
}) => {
  const emojifiedHtml = useEmojify(htmlString, extraEmojis);

  if (emojifiedHtml === null) {
    return null;
  }

  return <div {...props} dangerouslySetInnerHTML={{ __html: emojifiedHtml }} />;
};
