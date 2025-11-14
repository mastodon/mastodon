import type { FC } from 'react';

import type { SkinToneKey } from 'emojibase';

import { useLocaleMessages } from './hooks';
import classes from './styles.module.css';

const toneToEmoji: Record<SkinToneKey, string> = {
  light: '👋🏻',
  'medium-light': '👋🏼',
  medium: '👋🏽',
  'medium-dark': '👋🏾',
  dark: '👋🏿',
};

export const PickerSettings: FC = () => {
  const { skinTones } = useLocaleMessages();
  return (
    <div className={classes.main}>
      <h1>Emoji Settings</h1>
      <label>
        <select>
          <option value='default' title='Default skin tone'>
            👋
          </option>
          {skinTones.map((tone) => (
            <option key={tone.key} value={tone.key} title={tone.message}>
              {toneToEmoji[tone.key]}
            </option>
          ))}
        </select>{' '}
        Skin tone
      </label>
    </div>
  );
};
