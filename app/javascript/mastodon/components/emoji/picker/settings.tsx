import { useCallback, useMemo, useState } from 'react';
import type { ChangeEventHandler, FC } from 'react';

import { IconButton } from '@/mastodon/components/icon_button';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';

import { Emoji } from '..';

import type { CustomGroupMessage, SkinTone } from './constants';
import {
  mockCustomEmojis,
  mockCustomGroups,
  toneToEmoji,
  usePickerContext,
} from './constants';
import { useLocaleMessages } from './hooks';
import classes from './styles.module.css';

interface PickerSettingsProps {
  onClose: () => void;
  onSkinToneChange?: (skinTone: SkinTone) => void;
  onClearRecentlyUsed: () => void;
  onToggleHiddenGroup: (group: string) => void;
}

export const PickerSettings: FC<PickerSettingsProps> = ({
  onClose,
  onSkinToneChange,
  onToggleHiddenGroup,
  onClearRecentlyUsed,
}) => {
  const [editHidden, setEditHidden] = useState(false);
  const handleEditHiddenClick = useCallback(() => {
    setEditHidden((prev) => !prev);
  }, []);

  return (
    <>
      <div className={classes.header}>
        <h2>Emoji Picker Settings</h2>
        <IconButton
          icon='close'
          iconComponent={CloseIcon}
          title='Close settings'
          onClick={onClose}
        />
      </div>
      <div className={classes.settings}>
        {!editHidden ? (
          <>
            <fieldset>
              <legend>Skin tone</legend>
              <SkinToneSelector onSkinToneChange={onSkinToneChange} />
            </fieldset>
            <button type='button' onClick={handleEditHiddenClick}>
              Edit hidden groups
            </button>
            <button type='button' onClick={onClearRecentlyUsed}>
              Reset recently used
            </button>
          </>
        ) : (
          <HiddenGroupsSelector
            onClose={handleEditHiddenClick}
            onToggleHiddenGroup={onToggleHiddenGroup}
          />
        )}
      </div>
    </>
  );
};

const SkinToneSelector: FC<Pick<PickerSettingsProps, 'onSkinToneChange'>> = ({
  onSkinToneChange,
}) => {
  const [skinTone, setSkinTone] = useState<SkinTone>('default');
  const { skinTones } = useLocaleMessages();
  const toneMessages = useMemo(() => {
    return Object.entries(toneToEmoji).map(([key, emoji]) => ({
      key,
      emoji,
      message: skinTones.find((tone) => tone.key === key)?.message ?? key,
    }));
  }, [skinTones]);

  const handleSkinToneChange: ChangeEventHandler<HTMLInputElement> =
    useCallback(
      (event) => {
        const tone = event.currentTarget.value;
        if (tone === 'default' || tone in toneToEmoji) {
          setSkinTone(tone as SkinTone);
          onSkinToneChange?.(tone as SkinTone);
        }
      },
      [onSkinToneChange],
    );

  return (
    <div className={classes.skinTonesWrapper}>
      {toneMessages.map((tone) => (
        <input
          type='radio'
          name='skin-tone'
          key={tone.key}
          value={tone.key}
          title={tone.message}
          checked={skinTone === tone.key}
          onChange={handleSkinToneChange}
          data-emoji={tone.emoji}
        />
      ))}
    </div>
  );
};

const HiddenGroupsSelector: FC<
  Pick<PickerSettingsProps, 'onToggleHiddenGroup'> & { onClose: () => void }
> = ({ onClose, onToggleHiddenGroup }) => {
  return (
    <fieldset>
      <legend className={classes.hiddenGroupHeader}>
        <span>Uncheck to hide groups</span>
        <button type='button' onClick={onClose}>
          Go back
        </button>
      </legend>
      <ul>
        {mockCustomGroups.map((group) => (
          <HiddenGroupItem
            group={group}
            key={group.key}
            onToggleHiddenGroup={onToggleHiddenGroup}
          />
        ))}
      </ul>
    </fieldset>
  );
};

const HiddenGroupItem: FC<
  Pick<PickerSettingsProps, 'onToggleHiddenGroup'> & {
    group: CustomGroupMessage;
  }
> = ({ group, onToggleHiddenGroup }) => {
  const groupEmoji = useMemo(
    () => mockCustomEmojis.find((e) => e.category === group.key),
    [group],
  );
  const handleToggle = useCallback(() => {
    onToggleHiddenGroup(group.key);
  }, [onToggleHiddenGroup, group.key]);

  const { hiddenGroups } = usePickerContext();

  return (
    <li key={group.key}>
      <label className={classes.hiddenGroupItem}>
        <input
          type='checkbox'
          onChange={handleToggle}
          checked={!hiddenGroups.includes(group.key)}
        />
        <Emoji code={`:${groupEmoji?.shortcode}:`} />
        {group.message}
      </label>
    </li>
  );
};
