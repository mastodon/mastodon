import { useCallback, useMemo, useRef, useState } from 'react';
import type { FC, MouseEventHandler } from 'react';

import classNames from 'classnames';

import { fromUnicodeToHexcode } from 'emojibase';

import {
  loadEmojiByHexcode,
  loadUnicodeEmojiGroup,
} from '@/mastodon/features/emoji/database';
import { useEmojiAppState } from '@/mastodon/features/emoji/mode';
import { emojiToUnicodeHex } from '@/mastodon/features/emoji/normalize';
import type { AnyEmojiData } from '@/mastodon/features/emoji/types';
import { isCustomEmoji } from '@/mastodon/features/emoji/utils';
import ArrowIcon from '@/material-icons/400-24px/arrow_drop_down.svg?react';

import { Emoji } from '..';

import {
  groupKeysToNumber,
  mockCustomEmojis,
  usePickerContext,
} from './constants';
import classes from './styles.module.css';
import { emojiToKey } from './utils';

interface PickerGroupListProps {
  group: string;
  name: string;
  onInfoOpen: (emoji: AnyEmojiData) => void;
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
    const emojisToKeys = emojis?.map((e) => emojiToKey(e)) ?? [];
    const unicodeKeys = emojiKeys
      .filter((key) => !isCustomEmoji(key))
      .map((code) => fromUnicodeToHexcode(code))
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

    void Promise.all(
      missingUnicodeKeys.map((code) => loadEmojiByHexcode(code, currentLocale)),
    ).then((unicodeEmojis) => {
      setEmojis((prevEmojis) => {
        setLoading(false);
        return mergeNewEmojis(
          prevEmojis ?? [],
          unicodeEmojis.filter((e) => !!e),
          emojiKeys,
        );
      });
    });
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

  // If there is an emoji but no key, remove it.
  if (emojis !== null && emojis.length > emojiKeys.length) {
    setEmojis(
      (prevEmojis) =>
        prevEmojis?.filter((emoji) => emojiKeys.includes(emojiToKey(emoji))) ??
        [],
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

function mergeNewEmojis(
  currentEmojis: AnyEmojiData[],
  newEmojis: AnyEmojiData[],
  emojiKeys: string[],
): AnyEmojiData[] {
  if (newEmojis.length === 0) {
    return currentEmojis;
  }
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
      .map((key) => allEmojis.get(fromUnicodeToHexcode(key)))
      // Discard any missing emojis.
      .filter((e) => !!e)
  );
}

const PickerGroupListInner: FC<
  PickerGroupListProps & { emojis: AnyEmojiData[] | null }
> = ({ group, name, emojis, onInfoOpen }) => {
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
              onInfoOpen={onInfoOpen}
            />
          ))}
        </ul>
      )}
    </div>
  );
};

interface PickerListEmojiProps {
  emoji: AnyEmojiData;
  onInfoOpen: (emoji: AnyEmojiData) => void;
}

const PRESS_DURATION = 300; // ms

const PickerListEmoji: FC<PickerListEmojiProps> = ({ emoji, onInfoOpen }) => {
  const { onSelect } = usePickerContext();
  const code = emojiToKey(emoji, false);

  // On mouse down, start a timer. If it completes, show info and clear the ref.
  const pressTimerRef = useRef<number | null>(null);
  const handleMouseDown: MouseEventHandler = useCallback(() => {
    pressTimerRef.current = window.setTimeout(() => {
      onInfoOpen(emoji);
      pressTimerRef.current = null;
    }, PRESS_DURATION);
  }, [emoji, onInfoOpen]);

  // On mouse up before timer completes, select the emoji.
  const handleMouseUp: MouseEventHandler = useCallback(() => {
    if (pressTimerRef.current) {
      clearTimeout(pressTimerRef.current);
      pressTimerRef.current = null;
      onSelect(code);
    }
  }, [code, onSelect]);

  const handleContextMenu: MouseEventHandler = useCallback(
    (event) => {
      event.preventDefault();
      onInfoOpen(emoji);
    },
    [emoji, onInfoOpen],
  );

  return (
    <li>
      <button
        type='button'
        title={'unicode' in emoji ? emoji.label : `:${emoji.shortcode}:`}
        onContextMenu={handleContextMenu}
        onMouseDown={handleMouseDown}
        onMouseUp={handleMouseUp}
        onMouseLeave={handleMouseUp}
        className={classes.listButton}
      >
        <Emoji code={code} />
      </button>
    </li>
  );
};
