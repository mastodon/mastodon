import type {
  ChangeEvent,
  ChangeEventHandler,
  ComponentPropsWithoutRef,
  FC,
  ReactNode,
  RefObject,
} from 'react';
import { useCallback, useId, useRef } from 'react';

import { insertEmojiAtPosition } from '@/mastodon/features/emoji/utils';
import type { OmitUnion } from '@/mastodon/utils/types';

import { CharacterCounter } from '../character_counter';
import { EmojiPickerButton } from '../emoji/picker_button';

import classes from './emoji_text_field.module.scss';
import type { CommonFieldWrapperProps, InputProps } from './form_field_wrapper';
import { FormFieldWrapper } from './form_field_wrapper';
import { TextArea } from './text_area_field';
import type { TextAreaProps } from './text_area_field';
import { TextInput } from './text_input_field';

export type EmojiInputProps = {
  value?: string;
  onChange?: (newValue: string) => void;
  counterMax?: number;
  recommended?: boolean;
} & Omit<CommonFieldWrapperProps, 'wrapperClassName'>;

export const EmojiTextInputField: FC<
  OmitUnion<ComponentPropsWithoutRef<'input'>, EmojiInputProps>
> = ({
  onChange,
  value,
  label,
  hint,
  status,
  maxLength,
  counterMax = maxLength,
  recommended,
  disabled,
  ...otherProps
}) => {
  const inputRef = useRef<HTMLInputElement>(null);

  const wrapperProps = {
    label,
    hint,
    status,
    counterMax,
    recommended,
    disabled,
    inputRef,
    value,
    onChange,
  };

  return (
    <EmojiFieldWrapper {...wrapperProps}>
      {(inputProps) => (
        <TextInput
          {...inputProps}
          {...otherProps}
          maxLength={maxLength}
          value={value}
          ref={inputRef}
        />
      )}
    </EmojiFieldWrapper>
  );
};

export const EmojiTextAreaField: FC<
  OmitUnion<Omit<TextAreaProps, 'style'>, EmojiInputProps>
> = ({
  onChange,
  value,
  label,
  maxLength,
  counterMax = maxLength,
  recommended,
  disabled,
  hint,
  status,
  ...otherProps
}) => {
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  const wrapperProps = {
    label,
    hint,
    status,
    counterMax,
    recommended,
    disabled,
    inputRef: textareaRef,
    value,
    onChange,
  };

  return (
    <EmojiFieldWrapper {...wrapperProps}>
      {(inputProps) => (
        <TextArea
          {...otherProps}
          {...inputProps}
          maxLength={maxLength}
          value={value}
          ref={textareaRef}
        />
      )}
    </EmojiFieldWrapper>
  );
};

const EmojiFieldWrapper: FC<
  EmojiInputProps & {
    disabled?: boolean;
    children: (
      inputProps: InputProps & { onChange: ChangeEventHandler },
    ) => ReactNode;
    inputRef: RefObject<HTMLTextAreaElement | HTMLInputElement>;
  }
> = ({
  value,
  onChange,
  children,
  disabled,
  inputRef,
  counterMax,
  recommended = false,
  ...otherProps
}) => {
  const counterId = useId();

  const handlePickEmoji = useCallback(
    (emoji: string) => {
      if (!value) {
        onChange?.('');
        return;
      }
      const position = inputRef.current?.selectionStart ?? value.length;
      const newValue = insertEmojiAtPosition(value, emoji, position);
      onChange?.(newValue);
    },
    [inputRef, value, onChange],
  );

  const handleChange = useCallback(
    (event: ChangeEvent<HTMLInputElement>) => {
      onChange?.(event.target.value);
    },
    [onChange],
  );

  return (
    <FormFieldWrapper
      className={classes.fieldWrapper}
      describedById={counterId}
      {...otherProps}
    >
      {(inputProps) => (
        <>
          {children({ ...inputProps, onChange: handleChange })}
          <EmojiPickerButton onPick={handlePickEmoji} disabled={disabled} />
          {counterMax && (
            <CharacterCounter
              currentString={value ?? ''}
              maxLength={counterMax}
              recommended={recommended}
              id={counterId}
            />
          )}
        </>
      )}
    </FormFieldWrapper>
  );
};
