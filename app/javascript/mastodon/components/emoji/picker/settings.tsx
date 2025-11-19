import { useCallback, useMemo, useState } from 'react';
import type { ChangeEventHandler, FC } from 'react';

import CloseIcon from '@/material-icons/400-24px/close.svg?react';

import { IconButton } from '../../icon_button';

import type { SkinTone } from './constants';
import { toneToEmoji } from './constants';
import { useLocaleMessages } from './hooks';
import classes from './styles.module.css';

interface PickerSettingsProps {
  onClose: () => void;
  onSkinToneChange?: (skinTone: SkinTone) => void;
}

export const PickerSettings: FC<PickerSettingsProps> = ({
  onClose,
  onSkinToneChange,
}) => {
  return (
    <>
      <div className={classes.header}>
        <h2 className={classes.headerTitle}>Emoji Picker Settings</h2>
        <IconButton
          icon='close'
          iconComponent={CloseIcon}
          title='Close settings'
          onClick={onClose}
        />
      </div>
      <div className={classes.settings}>
        <fieldset>
          <legend>Skin tone</legend>
          <SkinToneSelector onSkinToneChange={onSkinToneChange} />
        </fieldset>
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
