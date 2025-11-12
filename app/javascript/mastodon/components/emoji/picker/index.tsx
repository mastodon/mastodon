import { useCallback, useState } from 'react';
import type { FC, MouseEventHandler } from 'react';

import messages from 'emojibase-data/en/messages.json';

import { loadUnicodeEmojiGroupIcon } from '@/mastodon/features/emoji/database';
import { useEmojiAppState } from '@/mastodon/features/emoji/mode';
import type {
  CustomEmojiData,
  UnicodeEmojiData,
} from '@/mastodon/features/emoji/types';
import SettingsIcon from '@/material-icons/400-24px/settings.svg?react';

import { Emoji } from '..';
import { IconButton } from '../../icon_button';
import { CustomEmojiProvider } from '../context';

import {
  groupKeysToNumber,
  mockCustomEmojis,
  mockCustomGroups,
} from './constants';
import classes from './styles.module.css';

export const MockEmojiPicker: FC = () => {
  const handleGroupSelect = useCallback((key: string) => {
    // eslint-disable-next-line no-console
    console.log('Selected group:', key);
  }, []);

  const [showSettings, setShowSettings] = useState(false);
  const handleSettingsClick: MouseEventHandler = useCallback((event) => {
    event.preventDefault();
    setShowSettings((prev) => !prev);
  }, []);

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
        {!showSettings && <div className={classes.main} />}
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
          {messages.groups.map((group) => (
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
  const icon = useGroupIcon(group);

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

function useGroupIcon(groupKey: string) {
  const { currentLocale } = useEmojiAppState();
  const [icon, setIcon] = useState<UnicodeEmojiData | CustomEmojiData | null>(
    () => {
      const emoji = mockCustomEmojis.find(
        (emoji) => emoji.category === groupKey,
      );
      return emoji ?? null;
    },
  );

  if (groupKey in groupKeysToNumber) {
    const group = groupKeysToNumber[groupKey];
    if (typeof group !== 'undefined') {
      void loadUnicodeEmojiGroupIcon(group, currentLocale).then(setIcon);
    }
  }
  return icon;
}
