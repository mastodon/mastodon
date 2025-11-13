import type { FC, MouseEventHandler } from 'react';
import { useCallback, useState, useEffect } from 'react';

import classNames from 'classnames';

import { loadUnicodeEmojiGroupIcon } from '@/mastodon/features/emoji/database';
import { useEmojiAppState } from '@/mastodon/features/emoji/mode';
import type { AnyEmojiData } from '@/mastodon/features/emoji/types';

import { Emoji } from '..';

import { mockCustomEmojis, groupKeysToNumber } from './constants';
import classes from './styles.module.css';

interface PickerGroupButtonProps {
  onSelect: (key: string) => void;
  group: string;
  message: string;
  disabled?: boolean;
}

export const PickerGroupButton: FC<PickerGroupButtonProps> = ({
  onSelect,
  message,
  group,
  disabled = false,
}) => {
  const handleClick: MouseEventHandler = useCallback(
    (event) => {
      event.preventDefault();
      onSelect(group);
    },
    [onSelect, group],
  );
  const { currentLocale } = useEmojiAppState();
  const [icon, setIcon] = useState<AnyEmojiData | null>(() => {
    const emoji = mockCustomEmojis.find((emoji) => emoji.category === group);
    return emoji ?? null;
  });

  useEffect(() => {
    if (icon !== null) {
      return;
    }

    if (group in groupKeysToNumber) {
      const groupNum = groupKeysToNumber[group];
      if (typeof groupNum !== 'undefined') {
        void loadUnicodeEmojiGroupIcon(groupNum, currentLocale).then(setIcon);
      }
    }
  }, [currentLocale, group, icon]);

  return (
    <li>
      <button
        type='button'
        title={message}
        onClick={handleClick}
        className={classNames(classes.groupButton)}
        disabled={disabled}
      >
        {icon && (
          <Emoji
            code={'unicode' in icon ? icon.unicode : `:${icon.shortcode}:`}
          />
        )}
      </button>
    </li>
  );
};
