import { useEffect, useMemo, useState } from 'react';

import { usePrevious } from '@dnd-kit/utilities';
import type { MessagesDataset } from 'emojibase';
import enMessages from 'emojibase-data/en/messages.json';

import { loadEmojisByCodes } from '@/mastodon/features/emoji/database';
import { useEmojiAppState } from '@/mastodon/features/emoji/mode';
import type { AnyEmojiData } from '@/mastodon/features/emoji/types';

import { groupsToHide } from './constants';

export function useEmojisFromCodes(codes: string[]) {
  const { currentLocale } = useEmojiAppState();
  const [emojis, setEmojis] = useState<AnyEmojiData[] | null>(null);

  useEffect(() => {
    void loadEmojisByCodes(codes, currentLocale).then(setEmojis);
  }, [codes, currentLocale]);

  return emojis;
}

export function useLocaleMessages() {
  const { currentLocale } = useEmojiAppState();
  // This isn't needed in real life, as the current locale is only set on page load.
  // However it Storybook can update the locale without a refresh.
  const prevLocale = usePrevious(currentLocale);

  const [messages, setMessages] = useState<MessagesDataset>(enMessages);
  if (prevLocale !== currentLocale) {
    // This is messy, but it's just for the mock picker.
    import(
      `../../../../../../node_modules/emojibase-data/${currentLocale}/messages.json`
    )
      .then((module: { default: MessagesDataset }) => {
        setMessages(module.default);
      })
      .catch((err: unknown) => {
        console.warn('fell back to en messages', err);
      });
  }

  const groups = useMemo(
    () => messages.groups.filter((group) => !groupsToHide.includes(group.key)),
    [messages.groups],
  );

  return {
    ...messages,
    groups,
  };
}
