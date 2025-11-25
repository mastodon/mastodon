import { useCallback, useMemo, useState } from 'react';
import type { FC, MouseEventHandler } from 'react';

import classNames from 'classnames';

import {
  loadUnicodeEmojiGroup,
  searchEmojisByHexcodes,
} from '@/mastodon/features/emoji/database';
import { useEmojiAppState } from '@/mastodon/features/emoji/mode';
import { emojiToUnicodeHex } from '@/mastodon/features/emoji/normalize';
import type { AnyEmojiData } from '@/mastodon/features/emoji/types';
import { isCustomEmoji } from '@/mastodon/features/emoji/utils';
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
  ...props
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

  return <PickerGroupListInner group={group} emojis={emojis} {...props} />;
};

export const PickerGroupCustomList: FC<
  PickerGroupListProps & { emojiKeys: string[] }
> = ({ emojiKeys, ...props }) => {
  // Start the state with any custom emojis we already have.
  const [emojis, setEmojis] = useState<AnyEmojiData[] | null>(() => {
    const customEmojis = mockCustomEmojis.filter((emoji) =>
      emojiKeys.includes(`:${emoji.shortcode}:`),
    );
    return customEmojis.length > 0 ? customEmojis : null;
  });

  // Determine which missing keys are Unicode and which are custom.
  const [missingUnicodeKeys, missingCustomKeys] = useMemo(() => {
    const emojisToKeys = emojis?.map(emojiToKey) ?? [];
    const unicodeKeys = emojiKeys
      .filter((key) => !isCustomEmoji(key))
      .map((code) => emojiToUnicodeHex(code))
      .filter((code) => !emojisToKeys.includes(code));
    const customKeys = emojiKeys.filter(
      (key) => isCustomEmoji(key) && !emojisToKeys.includes(key),
    );
    return [unicodeKeys, customKeys];
  }, [emojiKeys, emojis]);

  // Next, load all Unicode emojis.
  const { currentLocale } = useEmojiAppState();
  const [loading, setLoading] = useState(false); // Use to avoid duplicate loads.
  if (missingUnicodeKeys.length > 0 && !loading) {
    setLoading(true);

    void searchEmojisByHexcodes(missingUnicodeKeys, currentLocale).then(
      (unicodeEmojis) => {
        setEmojis((prevEmojis) => {
          setLoading(false);
          return mergeNewEmojis(prevEmojis ?? [], unicodeEmojis, emojiKeys);
        });
      },
    );
  }

  // Finally, load all custom emojis that haven't been loaded yet.
  if (missingCustomKeys.length > 0) {
    setEmojis((prevEmojis) => {
      const newCustomEmojis = mockCustomEmojis.filter((emoji) =>
        missingCustomKeys.includes(`:${emoji.shortcode}:`),
      );
      return mergeNewEmojis(prevEmojis ?? [], newCustomEmojis, emojiKeys);
    });
  }

  return <PickerGroupListInner emojis={emojis} {...props} />;
};

function emojiToKey(emoji: AnyEmojiData): string {
  return 'hexcode' in emoji ? emoji.hexcode : `:${emoji.shortcode}:`;
}

function mergeNewEmojis(
  currentEmojis: AnyEmojiData[],
  newEmojis: AnyEmojiData[],
  emojiKeys: string[],
): AnyEmojiData[] {
  const allEmojis = new Map([
    ...currentEmojis.map(
      (emoji) => [emojiToKey(emoji), emoji] satisfies [string, AnyEmojiData],
    ),
    ...newEmojis.map(
      (emoji) => [emojiToKey(emoji), emoji] satisfies [string, AnyEmojiData],
    ),
  ]);

  return (
    emojiKeys
      .map((key) =>
        isCustomEmoji(key)
          ? allEmojis.get(key)
          : allEmojis.get(emojiToUnicodeHex(key)),
      )
      // Discard any missing emojis.
      .filter((e) => !!e)
  );
}

const PickerGroupListInner: FC<
  PickerGroupListProps & { emojis: AnyEmojiData[] | null }
> = ({ group, name, onSelect, emojis }) => {
  const [isMinimized, setMinimized] = useState(false);
  const handleToggleMinimize = useCallback(() => {
    setMinimized((prev) => !prev);
  }, []);

  // If loaded and there are no emojis, don't render the group at all.
  if (emojis !== null && emojis.length === 0) {
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
      {!isMinimized && emojis !== null && (
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
