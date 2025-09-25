import { useMemo } from 'react';
import type { ComponentPropsWithoutRef, ElementType } from 'react';

import classNames from 'classnames';

import { Emoji } from '@/mastodon/components/emoji';
import { CustomEmojiProvider } from '@/mastodon/components/emoji/context';
import { isModernEmojiEnabled } from '@/mastodon/utils/environment';
import { htmlStringToComponents } from '@/mastodon/utils/html';

import { cleanExtraEmojis } from './normalize';
import { tokenizeText } from './render';
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

function onText(text: string) {
  return tokenizeText(text).map((token, index) => {
    if (typeof token === 'string') {
      return token;
    }
    return <Emoji code={token.code} key={`emoji-${token.code}-${index}`} />;
  });
}

export const ModernEmojiHTML = ({
  extraEmojis: rawExtraEmojis,
  htmlString,
  as: Wrapper = 'div', // Rename for syntax highlighting
  shallow,
  className = '',
  ...props
}: EmojiHTMLProps<ElementType>) => {
  const contents = useMemo(
    () => htmlStringToComponents(htmlString, { onText }),
    [htmlString],
  );
  const extraEmojis = useMemo(
    () => cleanExtraEmojis(rawExtraEmojis),
    [rawExtraEmojis],
  );
  const components = (
    <Wrapper {...props} className={className}>
      {contents}
    </Wrapper>
  );
  if (!extraEmojis) {
    return components;
  }
  return (
    <CustomEmojiProvider emoji={extraEmojis}>{components}</CustomEmojiProvider>
  );
};

export const EmojiHTML = <Element extends ElementType>(
  props: EmojiHTMLProps<Element>,
) => {
  if (isModernEmojiEnabled()) {
    return <ModernEmojiHTML {...props} />;
  }
  const {
    as: asElement,
    htmlString,
    extraEmojis,
    className,
    shallow,
    ...rest
  } = props;
  const Wrapper = asElement ?? 'div';
  return (
    <Wrapper
      {...rest}
      dangerouslySetInnerHTML={{ __html: htmlString }}
      className={classNames(className, 'animate-parent')}
    />
  );
};
