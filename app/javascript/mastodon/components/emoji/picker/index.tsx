import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import type { FC } from 'react';

import { IconButton } from '@/mastodon/components/icon_button';
import type { AnyEmojiData } from '@/mastodon/features/emoji/types';
import SettingsIcon from '@/material-icons/400-24px/settings.svg?react';

import { CustomEmojiProvider } from '../context';

import type { SkinTone } from './constants';
import {
  mockCustomEmojis,
  mockCustomGroups,
  PickerContextProvider,
  usePickerContext,
} from './constants';
import { PickerGroupButton } from './group-button';
import { useLocaleMessages } from './hooks';
import { PickerEmojiInfo } from './info';
import { PickerGroupCustomList, PickerGroupList } from './list';
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

  const [skinTone, setSkinTone] = useState<SkinTone>('default');
  const handleSkinToneChange = useCallback(
    (tone: SkinTone) => {
      setSkinTone(tone);
      onSkinToneChange?.(tone);
    },
    [onSkinToneChange],
  );

  const [recentlyUsed, setRecentlyUsed] = useState<string[]>([
    ':blobcat_heart:',
    ':mastodon:',
    '👍',
  ]);
  const handleClearRecentlyUsed = useCallback(() => {
    setRecentlyUsed([]);
  }, []);

  const handleEmojiPick = useCallback(
    (emojiCode: string) => {
      onSelect?.(emojiCode);
      if (!recentlyUsed.includes(emojiCode)) {
        setRecentlyUsed((prev) => [emojiCode, ...prev].slice(0, 10));
      }
    },
    [onSelect, recentlyUsed],
  );

  const [hiddenGroups, setHiddenGroups] = useState<string[]>([]);
  const handleToggleHiddenGroup = useCallback((group: string) => {
    setHiddenGroups((prev) =>
      prev.includes(group) ? prev.filter((g) => g !== group) : [...prev, group],
    );
  }, []);

  const [favourites, setFavourites] = useState<string[]>(['🖤']);
  const handleToggleFavourite = useCallback((emojiCode: string) => {
    const emojiKey = emojiCode;
    setFavourites((prev) => {
      const prevCodes = new Set(prev);
      if (prevCodes.has(emojiKey)) {
        prevCodes.delete(emojiKey);
      } else {
        prevCodes.add(emojiKey);
      }
      return Array.from(prevCodes);
    });
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
      <PickerContextProvider
        value={{
          skinTone,
          hiddenGroups,
          favourites,
          recentlyUsed,
          onSelect: handleEmojiPick,
          onFavourite: handleToggleFavourite,
        }}
      >
        <div className={classes.wrapper}>
          {showSettings ? (
            <PickerSettings
              onClose={handleSettingsClick}
              onSkinToneChange={handleSkinToneChange}
              onToggleHiddenGroup={handleToggleHiddenGroup}
              onClearRecentlyUsed={handleClearRecentlyUsed}
            />
          ) : (
            <PickerMain onSettingsClick={handleSettingsClick} />
          )}
        </div>
      </PickerContextProvider>
    </CustomEmojiProvider>
  );
};

interface PickerMainProps {
  onSettingsClick: () => void;
}

const PickerMain: FC<PickerMainProps> = ({ onSettingsClick }) => {
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

  const pickerContext = usePickerContext();
  const { hiddenGroups, favourites, recentlyUsed } = pickerContext;
  const customGroups = useMemo(
    () => mockCustomGroups.filter(({ key }) => !hiddenGroups.includes(key)),
    [hiddenGroups],
  );

  const [emojiInfo, setEmojiInfo] = useState<null | AnyEmojiData>(null);
  const handleInfoOpen = useCallback((emoji: AnyEmojiData) => {
    setEmojiInfo(emoji);
  }, []);
  const handleInfoClose = useCallback(() => {
    setEmojiInfo(null);
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
        {favourites.length > 0 && (
          <PickerGroupCustomList
            name='Favourites'
            group='favourites'
            emojiKeys={favourites}
            onInfoOpen={handleInfoOpen}
          />
        )}
        {recentlyUsed.length > 0 && (
          <PickerGroupCustomList
            name='Recently Used'
            group='recent'
            emojiKeys={recentlyUsed}
            onInfoOpen={handleInfoOpen}
          />
        )}
        {customGroups.map((group) => (
          <PickerGroupList
            key={group.key}
            group={group.key}
            name={group.message}
            onInfoOpen={handleInfoOpen}
          />
        ))}
        {groups.map((group) => (
          <PickerGroupList
            key={group.key}
            group={group.key}
            name={group.message}
            onInfoOpen={handleInfoOpen}
          />
        ))}
        {emojiInfo && (
          <PickerEmojiInfo emoji={emojiInfo} onClose={handleInfoClose} />
        )}
      </div>
      <ul className={classes.nav}>
        {customGroups.map((group) => (
          <PickerGroupButton
            key={group.key}
            onSelect={handleGroupSelect}
            message={group.message}
            group={group.key}
          />
        ))}
        {customGroups.length > 0 && (
          <li key='separator' className={classes.separator} />
        )}
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
