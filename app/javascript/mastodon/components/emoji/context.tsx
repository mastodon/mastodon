import type {
  ComponentPropsWithoutRef,
  ElementType,
  PropsWithChildren,
} from 'react';
import { createContext, useCallback, useState } from 'react';

import type { List as ImmutableList } from 'immutable';

import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';
import { autoPlayGif } from '@/mastodon/initial_state';
import { useAppSelector } from '@/mastodon/store';
import type { ExtraCustomEmojiMap } from 'mastodon/features/emoji/types';

// Animation context
export const AnimateEmojiContext = createContext(autoPlayGif ?? false);

// Polymorphic provider component
type AnimateEmojiProviderProps<Element extends ElementType = 'div'> =
  ComponentPropsWithoutRef<Element> & { as: Element } & PropsWithChildren;

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
  emoji,
}: PropsWithChildren<{ emoji: ExtraCustomEmojiMap }>) => {
  return (
    <CustomEmojiContext.Provider value={emoji}>
      {children}
    </CustomEmojiContext.Provider>
  );
};

export const RootCustomEmojiProvider = ({ children }: PropsWithChildren) => {
  const emoji = useAppSelector((state) =>
    (state.custom_emojis as ImmutableList<ApiCustomEmojiJSON>)
      .toJS()
      .reduce<ExtraCustomEmojiMap>(
        (acc, emoji) => ({ ...acc, [emoji.shortcode]: emoji }),
        {},
      ),
  );
  return (
    <CustomEmojiContext.Provider value={emoji}>
      {children}
    </CustomEmojiContext.Provider>
  );
};
