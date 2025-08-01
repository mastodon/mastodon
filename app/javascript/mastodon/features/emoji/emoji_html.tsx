import type { ComponentPropsWithoutRef, ElementType } from 'react';

import { useEmojify } from './hooks';
import type { CustomEmojiMapArg } from './types';

type EmojiHTMLProps<Element extends ElementType = 'div'> = Omit<
  ComponentPropsWithoutRef<Element>,
  'dangerouslySetInnerHTML' | 'className'
> & {
  htmlString: string;
  extraEmojis?: CustomEmojiMapArg;
  as?: Element;
  shallow?: boolean;
  className?: string;
};

export const EmojiHTML = ({
  extraEmojis,
  htmlString,
  as: Wrapper = 'div', // Rename for syntax highlighting
  shallow,
  className = '',
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
    <Wrapper
      {...props}
      className={`${className} animate-parent`}
      dangerouslySetInnerHTML={{ __html: emojifiedHtml }}
    />
  );
};
