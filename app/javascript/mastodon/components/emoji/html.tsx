import { useMemo } from 'react';

import type { CustomEmojiMapArg } from '@/mastodon/features/emoji/types';
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

export const EmojiHTML = polymorphicForwardRef<'div', EmojiHTMLProps>(
  (
    {
      extraEmojis,
      htmlString,
      as: asProp = 'div', // Rename for syntax highlighting
      className,
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
EmojiHTML.displayName = 'EmojiHTML';
