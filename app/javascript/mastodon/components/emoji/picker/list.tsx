import { useCallback, useState } from 'react';
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
import { usePrevious } from '@/mastodon/hooks/usePrevious';
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

  // Next, load all Unicode emojis.
  const { currentLocale } = useEmojiAppState();
  const prevKeyCount = usePrevious(emojiKeys.length) ?? null;
  if (
    prevKeyCount === null ||
    (prevKeyCount !== emojiKeys.length &&
      (emojis === null || emojis.length < emojiKeys.length))
  ) {
    // Convert to Unicode hex codes.
    const unicodeKeys = emojiKeys
      .filter((key) => !isCustomEmoji(key))
      .map((code) => emojiToUnicodeHex(code));
    if (unicodeKeys.length === 0) {
      return;
    }
    void searchEmojisByHexcodes(unicodeKeys, currentLocale).then(
      (unicodeEmojis) => {
        if (emojis?.length === emojiKeys.length) {
          return;
        }
        // Combine custom and Unicode emojis based on the original key order.
        setEmojis((prevEmojis) => {
          const combinedEmojis = prevEmojis ?? [];

          return (
            emojiKeys
              .map((key) => {
                if (isCustomEmoji(key)) {
                  return combinedEmojis.find(
                    (e) => 'shortcode' in e && e.shortcode === key.slice(1, -1),
                  );
                }
                return (
                  unicodeEmojis.find(
                    (e) => e.hexcode === emojiToUnicodeHex(key),
                  ) ?? null
                );
              })
              // Discard any unknown emojis.
              .filter((e): e is AnyEmojiData => !!e)
          );
        });
      },
    );
  }

  return <PickerGroupListInner emojis={emojis} {...props} />;
};

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
