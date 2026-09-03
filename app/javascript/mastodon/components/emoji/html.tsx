import { useMemo } from 'react';

import type { CustomEmojiMapArg } from '@/mastodon/features/emoji/types';
import type {
  OnAttributeHandler,
  OnElementHandler,
} from '@/mastodon/utils/html';
import { htmlStringToComponents } from '@/mastodon/utils/html';
import type { PolymorphicProps } from '@/types/polymorphic';

import { AnimateEmojiProvider, CustomEmojiProvider } from './context';
import { textToEmojis } from './index';

export interface EmojiHTMLProps<
  Arg extends Record<string, unknown> = Record<string, unknown>,
> {
  htmlString: string;
  extraEmojis?: CustomEmojiMapArg;
  className?: string;
  onElement?: OnElementHandler<Arg>;
  onAttribute?: OnAttributeHandler<Arg>;
  extraArgs?: Arg;
}

export const EmojiHTML = <
  As extends React.ElementType = 'div',
  Arg extends Record<string, unknown> = Record<string, unknown>,
>({
  extraEmojis,
  htmlString,
  onElement,
  onAttribute,
  extraArgs,
  ref,
  ...props
}: PolymorphicProps<EmojiHTMLProps<Arg>, As>) => {
  const contents = useMemo(
    () =>
      htmlStringToComponents(htmlString, {
        onText: textToEmojis,
        onElement,
        onAttribute,
        extraArgs,
      }),
    [extraArgs, htmlString, onAttribute, onElement],
  );

  return (
    <CustomEmojiProvider emojis={extraEmojis}>
      <AnimateEmojiProvider {...props} ref={ref}>
        {contents}
      </AnimateEmojiProvider>
    </CustomEmojiProvider>
  );
};
