import type {
  ChangeEvent,
  ComponentPropsWithoutRef,
  Dispatch,
  FC,
  ReactNode,
  SetStateAction,
} from 'react';
import { useCallback, useId, useRef } from 'react';

import {
  TextAreaField,
  TextInputField,
} from '@/mastodon/components/form_fields';
import type { TextAreaProps } from '@/mastodon/components/form_fields/text_area_field';
import type { OmitUnion } from '@/mastodon/utils/types';

import { insertEmojiAtPosition } from '../../emoji/utils';
import classes from '../styles.module.scss';

import { CharCounter } from './char_counter';
import { EmojiPicker } from './emoji_picker';

interface InputProps {
  value: string;
  onChange: Dispatch<SetStateAction<string>>;
  label?: ReactNode;
  hint?: ReactNode;
  maxLength?: number;
  recommended?: boolean;
}

export const TextInput: FC<
  OmitUnion<ComponentPropsWithoutRef<'input'>, InputProps>
> = ({ onChange, value, label, maxLength, recommended = false, ...props }) => {
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
      label={label}
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

export const TextAreaInput: FC<
  OmitUnion<Omit<TextAreaProps, 'style'>, InputProps>
> = ({ onChange, value, label, maxLength, recommended = false, ...props }) => {
  const textareaRef = useRef<HTMLTextAreaElement>(null);
  const counterId = useId();

  const handleChange = useCallback(
    (event: ChangeEvent<HTMLTextAreaElement>) => {
      onChange(event.target.value);
    },
    [onChange],
  );

  const handlePickEmoji = useCallback(
    (emoji: string) => {
      onChange((prev) => {
        const position = textareaRef.current?.selectionStart ?? prev.length;
        return insertEmojiAtPosition(prev, emoji, position);
      });
    },
    [onChange],
  );

  return (
    <TextAreaField
      {...props}
      label={label}
      value={value}
      onChange={handleChange}
      wrapperClassName={classes.inputWrapper}
      ref={textareaRef}
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
