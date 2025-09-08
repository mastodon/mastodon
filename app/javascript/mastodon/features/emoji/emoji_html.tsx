import type { ComponentPropsWithoutRef, ElementType } from 'react';

import { isModernEmojiEnabled } from '@/mastodon/utils/environment';

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

export const ModernEmojiHTML = ({
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

export const EmojiHTML = <Element extends ElementType>(
  props: EmojiHTMLProps<Element>,
) => {
  if (isModernEmojiEnabled()) {
    return <ModernEmojiHTML {...props} />;
  }
  const { as: asElement, htmlString, extraEmojis, ...rest } = props;
  const Wrapper = asElement ?? 'div';
  return <Wrapper {...rest} dangerouslySetInnerHTML={{ __html: htmlString }} />;
};
