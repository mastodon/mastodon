import type {
  ChangeEvent,
  ComponentPropsWithoutRef,
  Dispatch,
  FC,
  ReactNode,
  SetStateAction,
} from 'react';
import { useCallback, useId, useRef } from 'react';

import { TextInputField } from '@/mastodon/components/form_fields';
import type { OmitUnion } from '@/mastodon/utils/types';

import { insertEmojiAtPosition } from '../../emoji/utils';
import classes from '../styles.module.scss';

import { CharCounter } from './char_counter';
import { EmojiPicker } from './emoji_picker';

interface InputProps {
  value: string;
  onChange: Dispatch<SetStateAction<string>>;
  label: ReactNode;
  hint?: ReactNode;
  maxLength?: number;
  recommended?: boolean;
}

export const TextInput: FC<
  OmitUnion<ComponentPropsWithoutRef<'input'>, InputProps>
> = ({ onChange, value, maxLength, recommended = false, ...props }) => {
  const inputRef = useRef<HTMLInputElement>(null);
  const counterId = useId();

  const handleChange = useCallback(
    (event: ChangeEvent<HTMLInputElement>) => {
      onChange(event.target.value);
    },
    [onChange],
  );

  const handlePickEmoji = useCallback(
    (emoji: string) => {
      onChange((prev) => {
        const position = inputRef.current?.selectionStart ?? prev.length;
        return insertEmojiAtPosition(prev, emoji, position);
      });
    },
    [onChange],
  );

  return (
    <TextInputField
      {...props}
      value={value}
      onChange={handleChange}
      wrapperClassName={classes.inputWrapper}
      ref={inputRef}
      aria-describedby={counterId}
      afterInput={
        <>
          <EmojiPicker onPick={handlePickEmoji} />
          {maxLength && (
            <CharCounter
              currentLength={value.length}
              maxLength={maxLength}
              recommended={recommended}
              id={counterId}
            />
          )}
        </>
      }
    />
  );
};
