import { useCallback, useRef, useState } from 'react';
import type { FC, MouseEventHandler } from 'react';

import classNames from 'classnames';

import type { AnyEmojiData } from '@/mastodon/features/emoji/types';
import SettingsIcon from '@/material-icons/400-24px/settings.svg?react';

import { IconButton } from '../../icon_button';
import { CustomEmojiProvider } from '../context';

import { mockCustomEmojis, mockCustomGroups } from './constants';
import { PickerGroupButton } from './group-button';
import { useLocaleMessages } from './hooks';
import { PickerGroupList } from './list';
import { PickerSettings } from './settings';
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

  const [showSettings, setShowSettings] = useState(false);
  const handleSettingsClick: MouseEventHandler = useCallback((event) => {
    event.preventDefault();
    setShowSettings((prev) => !prev);
  }, []);

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

  const { groups } = useLocaleMessages();

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
        {showSettings && <PickerSettings />}
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
        <ul
          className={classNames(
            classes.nav,
            showSettings && classes.settingsNav,
          )}
        >
          {mockCustomGroups.map((group) => (
            <PickerGroupButton
              key={group.key}
              onSelect={handleGroupSelect}
              message={group.message}
              group={group.key}
              disabled={showSettings}
            />
          ))}
          <li key='separator' className={classes.separator} />
          {groups.map((group) => (
            <PickerGroupButton
              key={group.key}
              onSelect={handleGroupSelect}
              message={group.message}
              group={group.key}
              disabled={showSettings}
            />
          ))}
        </ul>
      </div>
    </CustomEmojiProvider>
  );
};
