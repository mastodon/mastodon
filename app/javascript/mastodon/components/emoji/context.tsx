import type {
  ComponentPropsWithoutRef,
  ElementType,
  PropsWithChildren,
} from 'react';
import { createContext, useCallback, useMemo, useState } from 'react';

import { cleanExtraEmojis } from '@/mastodon/features/emoji/normalize';
import { autoPlayGif } from '@/mastodon/initial_state';
import type {
  CustomEmojiMapArg,
  ExtraCustomEmojiMap,
} from 'mastodon/features/emoji/types';

// Animation context
export const AnimateEmojiContext = createContext(autoPlayGif ?? false);

// Polymorphic provider component
type AnimateEmojiProviderProps<Element extends ElementType = 'div'> =
  ComponentPropsWithoutRef<Element> & { as?: Element } & PropsWithChildren;

export const AnimateEmojiProvider = ({
  children,
  as: Wrapper = 'div',
  ...props
}: AnimateEmojiProviderProps<ElementType>) => {
  const [animate, setAnimate] = useState(autoPlayGif ?? false);

  const handleEnter = useCallback(() => {
    if (!autoPlayGif) {
      setAnimate(true);
    }
  }, []);
  const handleLeave = useCallback(() => {
    if (!autoPlayGif) {
      setAnimate(false);
    }
  }, []);

  return (
    <Wrapper {...props} onMouseEnter={handleEnter} onMouseLeave={handleLeave}>
      <AnimateEmojiContext.Provider value={animate}>
        {children}
      </AnimateEmojiContext.Provider>
    </Wrapper>
  );
};

// Handle custom emoji
export const CustomEmojiContext = createContext<ExtraCustomEmojiMap>({});

export const CustomEmojiProvider = ({
  children,
  emojis: rawEmojis,
}: PropsWithChildren<{ emojis?: CustomEmojiMapArg }>) => {
  const emojis = useMemo(() => cleanExtraEmojis(rawEmojis) ?? {}, [rawEmojis]);
  return (
    <CustomEmojiContext.Provider value={emojis}>
      {children}
    </CustomEmojiContext.Provider>
  );
};
