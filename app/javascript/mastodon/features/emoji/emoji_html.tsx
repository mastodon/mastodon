import type { ComponentPropsWithoutRef, ElementType } from 'react';

import classNames from 'classnames';

import { isModernEmojiEnabled } from '@/mastodon/utils/environment';

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

export const ModernEmojiHTML = ({
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
      className={classNames(className, 'animate-parent')}
      dangerouslySetInnerHTML={{ __html: emojifiedHtml }}
    />
  );
};

export const EmojiHTML = <Element extends ElementType>(
  props: EmojiHTMLProps<Element>,
) => {
  if (isModernEmojiEnabled()) {
    return <ModernEmojiHTML {...props} />;
  }
  const { as: asElement, htmlString, extraEmojis, className, ...rest } = props;
  const Wrapper = asElement ?? 'div';
  return (
    <Wrapper
      {...rest}
      dangerouslySetInnerHTML={{ __html: htmlString }}
      className={classNames(className, 'animate-parent')}
    />
  );
};
