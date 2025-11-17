import { useCallback, useState } from 'react';
import type { FC, MouseEventHandler } from 'react';

import classNames from 'classnames';

import { loadUnicodeEmojiGroup } from '@/mastodon/features/emoji/database';
import { useEmojiAppState } from '@/mastodon/features/emoji/mode';
import type { AnyEmojiData } from '@/mastodon/features/emoji/types';
import ArrowIcon from '@/material-icons/400-24px/arrow_drop_down.svg?react';

import { Emoji } from '..';

import { groupKeysToNumber, mockCustomEmojis } from './constants';
import classes from './styles.module.css';

interface PickerGroupListProps {
  group: string;
  name: string;
  onSelect: (emoji: AnyEmojiData) => void;
}

export const PickerGroupList: FC<PickerGroupListProps> = ({
  group,
  name,
  onSelect,
}) => {
  const [emojis, setEmojis] = useState<AnyEmojiData[] | null>(() => {
    const emojis = mockCustomEmojis.filter((emoji) => emoji.category === group);
    return emojis.length > 0 ? emojis : null;
  });

  const { currentLocale } = useEmojiAppState();
  if (group in groupKeysToNumber && emojis === null) {
    const groupNum = groupKeysToNumber[group];
    if (typeof groupNum !== 'undefined') {
      void loadUnicodeEmojiGroup(groupNum, currentLocale).then(setEmojis);
    }
  }

  const [isMinimized, setMinimized] = useState(false);
  const handleToggleMinimize = useCallback(() => {
    setMinimized((prev) => !prev);
  }, []);

  // Still loading emojis.
  if (emojis === null) {
    return null;
  }

  return (
    <div tabIndex={-1}>
      <h2
        className={classNames(
          classes.groupHeader,
          isMinimized && classes.isMinimized,
        )}
      >
        <button type='button' onClick={handleToggleMinimize} data-group={group}>
          {name}
          <ArrowIcon className={classes.groupHeaderArrow} />
        </button>
      </h2>
      {!isMinimized && (
        <ul className={classes.emojiGrid}>
          {emojis.map((emoji) => (
            <PickerListEmoji
              key={'unicode' in emoji ? emoji.hexcode : emoji.shortcode}
              emoji={emoji}
              onClick={onSelect}
            />
          ))}
        </ul>
      )}
    </div>
  );
};

interface PickerListEmojiProps {
  emoji: AnyEmojiData;
  onClick: (emoji: AnyEmojiData) => void;
}

const PickerListEmoji: FC<PickerListEmojiProps> = ({ emoji, onClick }) => {
  const handleClick: MouseEventHandler = useCallback(() => {
    onClick(emoji);
  }, [emoji, onClick]);
  return (
    <li>
      <button
        type='button'
        title={'unicode' in emoji ? emoji.label : `:${emoji.shortcode}:`}
        onClick={handleClick}
        className={classes.listButton}
      >
        <Emoji
          code={'unicode' in emoji ? emoji.unicode : `:${emoji.shortcode}:`}
        />
      </button>
    </li>
  );
};
