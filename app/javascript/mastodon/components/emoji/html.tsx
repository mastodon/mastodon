import { useMemo } from 'react';
import type { ComponentPropsWithoutRef, ElementType } from 'react';

import classNames from 'classnames';

import type { CustomEmojiMapArg } from '@/mastodon/features/emoji/types';
import { isModernEmojiEnabled } from '@/mastodon/utils/environment';
import { htmlStringToComponents } from '@/mastodon/utils/html';

import { CustomEmojiProvider } from './context';
import { textToEmojis } from './index';

type EmojiHTMLProps<Element extends ElementType = 'div'> = Omit<
  ComponentPropsWithoutRef<Element>,
  'dangerouslySetInnerHTML' | 'className'
> & {
  htmlString: string;
  extraEmojis?: CustomEmojiMapArg;
  as?: Element;
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
  const contents = useMemo(
    () => htmlStringToComponents(htmlString, { onText: textToEmojis }),
    [htmlString],
  );

  return (
    <CustomEmojiProvider emojis={extraEmojis}>
      <Wrapper {...props} className={className}>
        {contents}
      </Wrapper>
    </CustomEmojiProvider>
  );
};

export const LegacyEmojiHTML = <Element extends ElementType>(
  props: EmojiHTMLProps<Element>,
) => {
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

export const EmojiHTML = isModernEmojiEnabled()
  ? ModernEmojiHTML
  : LegacyEmojiHTML;
