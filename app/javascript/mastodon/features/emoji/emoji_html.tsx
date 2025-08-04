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
};

export const ModernEmojiHTML = <Element extends ElementType>({
  extraEmojis,
  htmlString,
  as: asElement, // Rename for syntax highlighting
  ...props
}: EmojiHTMLProps<Element>) => {
  const Wrapper = asElement ?? 'div';
  const emojifiedHtml = useEmojify(htmlString, extraEmojis);

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
  const Wrapper = props.as ?? 'div';
  return (
    <Wrapper
      {...props}
      dangerouslySetInnerHTML={{ __html: props.htmlString }}
    />
  );
};
