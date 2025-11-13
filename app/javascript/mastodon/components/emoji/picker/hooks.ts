import { useMemo, useState } from 'react';

import { usePrevious } from '@dnd-kit/utilities';
import type { MessagesDataset } from 'emojibase';
import enMessages from 'emojibase-data/en/messages.json';

import { useEmojiAppState } from '@/mastodon/features/emoji/mode';

import { groupsToHide } from './constants';

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
