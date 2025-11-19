import { useCallback, useEffect, useRef, useState } from 'react';
import type { FC } from 'react';

import type { AnyEmojiData } from '@/mastodon/features/emoji/types';
import SettingsIcon from '@/material-icons/400-24px/settings.svg?react';

import { IconButton } from '../../icon_button';
import { CustomEmojiProvider } from '../context';

import type { SkinTone } from './constants';
import { mockCustomEmojis, mockCustomGroups } from './constants';
import { PickerGroupButton } from './group-button';
import { useLocaleMessages } from './hooks';
import { PickerGroupList } from './list';
import { PickerSettings } from './settings';
import classes from './styles.module.css';

interface MockEmojiPickerProps {
  onSelect?: (emojiCode: string) => void;
  onSkinToneChange?: (skinTone: SkinTone) => void;
  searchText?: string;
}

export const MockEmojiPicker: FC<MockEmojiPickerProps> = ({
  onSelect,
  onSkinToneChange,
}) => {
  const [showSettings, setShowSettings] = useState(false);
  const handleSettingsClick = useCallback(() => {
    setShowSettings((prev) => !prev);
  }, []);

  return (
    <CustomEmojiProvider emojis={mockCustomEmojis}>
      <div className={classes.wrapper}>
        {showSettings ? (
          <PickerSettings
            onClose={handleSettingsClick}
            onSkinToneChange={onSkinToneChange}
          />
        ) : (
          <PickerMain
            onSelect={onSelect}
            onSettingsClick={handleSettingsClick}
          />
        )}
      </div>
    </CustomEmojiProvider>
  );
};

const PickerMain: FC<
  MockEmojiPickerProps & { onSettingsClick: () => void }
> = ({ onSelect, onSettingsClick }) => {
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

  const { groups } = useLocaleMessages();
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

  const searchRef = useRef<HTMLInputElement>(null);
  useEffect(() => {
    const searchInput = searchRef.current;
    if (!searchInput) return;

    searchInput.focus();
  }, []);
  return (
    <>
      <div className={classes.header}>
        <input
          type='search'
          placeholder='Search emojis'
          className={classes.search}
          ref={searchRef}
        />
        <IconButton
          icon='settings'
          iconComponent={SettingsIcon}
          title='Picker settings'
          onClick={onSettingsClick}
        />
      </div>

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
      <ul className={classes.nav}>
        {mockCustomGroups.map((group) => (
          <PickerGroupButton
            key={group.key}
            onSelect={handleGroupSelect}
            message={group.message}
            group={group.key}
          />
        ))}
        <li key='separator' className={classes.separator} />
        {groups.map((group) => (
          <PickerGroupButton
            key={group.key}
            onSelect={handleGroupSelect}
            message={group.message}
            group={group.key}
          />
        ))}
      </ul>
    </>
  );
};
