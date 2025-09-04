import type { ComponentPropsWithoutRef, ElementType } from 'react';

import { useEmojify } from './hooks';
import type { CustomEmojiMapArg } from './types';

type EmojiHTMLProps<Element extends ElementType = 'div'> = Omit<
  ComponentPropsWithoutRef<Element>,
  'dangerouslySetInnerHTML'
> & {
  htmlString: string;
  extraEmojis?: CustomEmojiMapArg;
  as?: Element;
  shallow?: boolean;
};

export const EmojiHTML = ({
  extraEmojis,
  htmlString,
  as: Wrapper = 'div', // Rename for syntax highlighting
  shallow,
  ...props
}: EmojiHTMLProps<ElementType>) => {
  const emojifiedHtml = useEmojify({
    text: htmlString,
    extraEmojis,
    deep: !shallow,
  });

  if (emojifiedHtml === null) {
    return null;
  }

  return (
    <Wrapper {...props} dangerouslySetInnerHTML={{ __html: emojifiedHtml }} />
  );
};
