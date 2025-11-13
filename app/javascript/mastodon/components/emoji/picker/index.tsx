import { useCallback, useEffect, useRef, useState } from 'react';
import type { FC, MouseEventHandler } from 'react';

import type { GroupMessage, MessagesDataset } from 'emojibase';
import messages from 'emojibase-data/en/messages.json';

import { loadUnicodeEmojiGroupIcon } from '@/mastodon/features/emoji/database';
import { useEmojiAppState } from '@/mastodon/features/emoji/mode';
import type { AnyEmojiData } from '@/mastodon/features/emoji/types';
import { usePrevious } from '@/mastodon/hooks/usePrevious';
import SettingsIcon from '@/material-icons/400-24px/settings.svg?react';

import { Emoji } from '..';
import { IconButton } from '../../icon_button';
import { CustomEmojiProvider } from '../context';

import {
  groupKeysToNumber,
  groupsToHide,
  mockCustomEmojis,
  mockCustomGroups,
} from './constants';
import { PickerGroupList } from './list';
import classes from './styles.module.css';

interface MockEmojiPickerProps {
  onSelect?: (emojiCode: string) => void;
}

export const MockEmojiPicker: FC<MockEmojiPickerProps> = ({ onSelect }) => {
  const handleEmojiSelect = useCallback(
    (emoji: AnyEmojiData) => {
      if (onSelect) {
        const code =
          'unicode' in emoji ? emoji.unicode : `:${emoji.shortcode}:`;
        onSelect(code);
      }
    },
    [onSelect],
  );

  const wrapperRef = useRef<HTMLDivElement>(null);
  const handleGroupSelect = useCallback((key: string) => {
    const wrapper = wrapperRef.current;
    if (!wrapper) return;

    if (mockCustomGroups.at(0)?.key === key) {
      wrapper.scrollTo({ top: 0, behavior: 'smooth' });
      return;
    }

    const groupHeader = wrapper.querySelector<HTMLHeadingElement>(
      `[data-group="${key}"]`,
    );
    if (groupHeader) {
      groupHeader.focus({ preventScroll: true });
      groupHeader.scrollIntoView({ behavior: 'smooth' });
    }
  }, []);

  const [showSettings, setShowSettings] = useState(false);
  const handleSettingsClick: MouseEventHandler = useCallback((event) => {
    event.preventDefault();
    setShowSettings((prev) => !prev);
  }, []);

  const { currentLocale } = useEmojiAppState();
  // This isn't needed in real life, as the current locale is only set on page load.
  const prevLocale = usePrevious(currentLocale);
  const [groups, setGroups] = useState<GroupMessage[]>([]);
  if (prevLocale !== currentLocale) {
    // This is messy, but it's just for the mock picker.
    import(
      `../../../../../../node_modules/emojibase-data/${currentLocale}/messages.json`
    )
      .then((module: { default: MessagesDataset }) => {
        setGroups(
          module.default.groups.filter(
            (group) => !groupsToHide.includes(group.key),
          ),
        );
      })
      .catch((err: unknown) => {
        console.warn('fell back to en messages', err);
        setGroups(
          messages.groups.filter((group) => !groupsToHide.includes(group.key)),
        );
      });
  }

  return (
    <CustomEmojiProvider emojis={mockCustomEmojis}>
      <div className={classes.wrapper}>
        <div className={classes.header}>
          <input
            type='search'
            placeholder='Search emojis'
            className={classes.search}
          />
          <IconButton
            icon='settings'
            iconComponent={SettingsIcon}
            title='Picker settings'
            onClick={handleSettingsClick}
          />
        </div>
        {showSettings && <div className={classes.main}>Settings here</div>}
        {!showSettings && (
          <div className={classes.main} ref={wrapperRef}>
            {mockCustomGroups.map((group) => (
              <PickerGroupList
                key={group.key}
                group={group.key}
                name={group.message}
                onSelect={handleEmojiSelect}
              />
            ))}
            {groups.map((group) => (
              <PickerGroupList
                key={group.key}
                group={group.key}
                name={group.message}
                onSelect={handleEmojiSelect}
              />
            ))}
          </div>
        )}
        <ul className={classes.nav}>
          {mockCustomGroups.map((group) => (
            <PickerNavButton
              key={group.key}
              onSelect={handleGroupSelect}
              message={group.message}
              group={group.key}
            />
          ))}
          <li key='separator' className={classes.separator} />
          {groups.map((group) => (
            <PickerNavButton
              key={group.key}
              onSelect={handleGroupSelect}
              message={group.message}
              group={group.key}
            />
          ))}
        </ul>
      </div>
    </CustomEmojiProvider>
  );
};

interface PickerNavProps {
  onSelect: (key: string) => void;
  group: string;
  message: string;
}

const PickerNavButton: FC<PickerNavProps> = ({ onSelect, message, group }) => {
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
        className={classes.groupButton}
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
