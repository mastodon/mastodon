import type { MouseEventHandler, PropsWithChildren } from 'react';
import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useState,
} from 'react';

import { cleanExtraEmojis } from '@/mastodon/features/emoji/normalize';
import { autoPlayGif } from '@/mastodon/initial_state';
import { polymorphicForwardRef } from '@/types/polymorphic';
import type {
  CustomEmojiMapArg,
  ExtraCustomEmojiMap,
} from 'mastodon/features/emoji/types';

// Animation context
export const AnimateEmojiContext = createContext<boolean | null>(null);

// Polymorphic provider component
type AnimateEmojiProviderProps = Required<PropsWithChildren> & {
  className?: string;
};

export const AnimateEmojiProvider = polymorphicForwardRef<
  'div',
  AnimateEmojiProviderProps
>(
  (
    {
      children,
      as: Wrapper = 'div',
      className,
      onMouseEnter,
      onMouseLeave,
      ...props
    },
    ref,
  ) => {
    const [animate, setAnimate] = useState(autoPlayGif ?? false);

    const handleEnter: MouseEventHandler<HTMLDivElement> = useCallback(
      (event) => {
        onMouseEnter?.(event);
        if (!autoPlayGif) {
          setAnimate(true);
        }
      },
      [onMouseEnter],
    );
    const handleLeave: MouseEventHandler<HTMLDivElement> = useCallback(
      (event) => {
        onMouseLeave?.(event);
        if (!autoPlayGif) {
          setAnimate(false);
        }
      },
      [onMouseLeave],
    );

    // If there's a parent context or GIFs autoplay, we don't need handlers.
    const parentContext = useContext(AnimateEmojiContext);
    if (parentContext !== null) {
      return (
        <Wrapper {...props} className={className} ref={ref}>
          {children}
        </Wrapper>
      );
    }

    return (
      <Wrapper
        {...props}
        className={className}
        onMouseEnter={handleEnter}
        onMouseLeave={handleLeave}
        ref={ref}
      >
        <AnimateEmojiContext.Provider value={animate}>
          {children}
        </AnimateEmojiContext.Provider>
      </Wrapper>
    );
  },
);
AnimateEmojiProvider.displayName = 'AnimateEmojiProvider';

// Handle custom emoji
export const CustomEmojiContext = createContext<ExtraCustomEmojiMap>({});

export const CustomEmojiProvider = ({
  children,
  emojis: rawEmojis,
}: PropsWithChildren<{ emojis?: CustomEmojiMapArg | null }>) => {
  const emojis = useMemo(() => cleanExtraEmojis(rawEmojis), [rawEmojis]);
  if (!emojis) {
    return children;
  }
  return (
    <CustomEmojiContext.Provider value={emojis}>
      {children}
    </CustomEmojiContext.Provider>
  );
};
