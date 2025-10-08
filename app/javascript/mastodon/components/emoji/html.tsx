import { useMemo } from 'react';

import classNames from 'classnames';

import type { CustomEmojiMapArg } from '@/mastodon/features/emoji/types';
import { isModernEmojiEnabled } from '@/mastodon/utils/environment';
import type {
  OnAttributeHandler,
  OnElementHandler,
} from '@/mastodon/utils/html';
import { htmlStringToComponents } from '@/mastodon/utils/html';
import { polymorphicForwardRef } from '@/types/polymorphic';

import { AnimateEmojiProvider, CustomEmojiProvider } from './context';
import { textToEmojis } from './index';

export interface EmojiHTMLProps {
  htmlString: string;
  extraEmojis?: CustomEmojiMapArg;
  className?: string;
  onElement?: OnElementHandler;
  onAttribute?: OnAttributeHandler;
}

export const ModernEmojiHTML = polymorphicForwardRef<'div', EmojiHTMLProps>(
  (
    {
      extraEmojis,
      htmlString,
      as: asProp = 'div', // Rename for syntax highlighting
      className = '',
      onElement,
      onAttribute,
      ...props
    },
    ref,
  ) => {
    const contents = useMemo(
      () =>
        htmlStringToComponents(htmlString, {
          onText: textToEmojis,
          onElement,
          onAttribute,
        }),
      [htmlString, onAttribute, onElement],
    );

    return (
      <CustomEmojiProvider emojis={extraEmojis}>
        <AnimateEmojiProvider
          {...props}
          as={asProp}
          className={className}
          ref={ref}
        >
          {contents}
        </AnimateEmojiProvider>
      </CustomEmojiProvider>
    );
  },
);
ModernEmojiHTML.displayName = 'ModernEmojiHTML';

export const LegacyEmojiHTML = polymorphicForwardRef<'div', EmojiHTMLProps>(
  (props, ref) => {
    const {
      as: asElement,
      htmlString,
      extraEmojis,
      className,
      onElement,
      onAttribute,
      ...rest
    } = props;
    const Wrapper = asElement ?? 'div';
    return (
      <Wrapper
        {...rest}
        ref={ref}
        dangerouslySetInnerHTML={{ __html: htmlString }}
        className={classNames(className, 'animate-parent')}
      />
    );
  },
);
LegacyEmojiHTML.displayName = 'LegacyEmojiHTML';

export const EmojiHTML = isModernEmojiEnabled()
  ? ModernEmojiHTML
  : LegacyEmojiHTML;
