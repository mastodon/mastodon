import type {
  ChangeEvent,
  ComponentPropsWithoutRef,
  Dispatch,
  FC,
  ReactNode,
  SetStateAction,
} from 'react';
import { useCallback, useId, useRef } from 'react';

import { insertEmojiAtPosition } from '@/mastodon/features/emoji/utils';
import type { OmitUnion } from '@/mastodon/utils/types';

import { CharacterCounter } from '../character_counter';
import { EmojiPickerButton } from '../emoji/picker_button';

import classes from './emoji_text_field.module.scss';
import { TextAreaField } from './text_area_field';
import type { TextAreaProps } from './text_area_field';
import { TextInputField } from './text_input_field';

export interface InputProps {
  value?: string;
  onChange?: Dispatch<SetStateAction<string>>;
  label?: ReactNode;
  hint?: ReactNode;
  maxLength?: number;
  recommended?: boolean;
}

export const EmojiTextInputField: FC<
  OmitUnion<ComponentPropsWithoutRef<'input'>, InputProps>
> = ({
  onChange,
  value,
  label,
  maxLength,
  recommended = false,
  disabled,
  ...props
}) => {
  const inputRef = useRef<HTMLInputElement>(null);
  const counterId = useId();

  const handleChange = useCallback(
    (event: ChangeEvent<HTMLInputElement>) => {
      onChange?.(event.target.value);
    },
    [onChange],
  );

  const handlePickEmoji = useCallback(
    (emoji: string) => {
      onChange?.((prev) => {
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
      wrapperClassName={classes.fieldWrapper}
      disabled={disabled}
      ref={inputRef}
      aria-describedby={counterId}
      afterInput={
        <>
          <EmojiPickerButton onPick={handlePickEmoji} disabled={disabled} />
          {maxLength && (
            <CharacterCounter
              currentString={value ?? ''}
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

export const EmojiTextAreaField: FC<
  OmitUnion<Omit<TextAreaProps, 'style'>, InputProps>
> = ({
  onChange,
  value,
  label,
  maxLength,
  recommended = false,
  disabled,
  ...props
}) => {
  const textareaRef = useRef<HTMLTextAreaElement>(null);
  const counterId = useId();

  const handleChange = useCallback(
    (event: ChangeEvent<HTMLTextAreaElement>) => {
      onChange?.(event.target.value);
    },
    [onChange],
  );

  const handlePickEmoji = useCallback(
    (emoji: string) => {
      onChange?.((prev) => {
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
      wrapperClassName={classes.fieldWrapper}
      disabled={disabled}
      ref={textareaRef}
      aria-describedby={counterId}
      afterInput={
        <>
          <EmojiPickerButton onPick={handlePickEmoji} disabled={disabled} />
          {maxLength && (
            <CharacterCounter
              currentString={value ?? ''}
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
