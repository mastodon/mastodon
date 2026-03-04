import type {
  ChangeEvent,
  ChangeEventHandler,
  ComponentPropsWithoutRef,
  Dispatch,
  FC,
  ReactNode,
  RefObject,
  SetStateAction,
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
  onChange?: Dispatch<SetStateAction<string>>;
  maxLength?: number;
  recommended?: boolean;
} & Omit<CommonFieldWrapperProps, 'wrapperClassName'>;

export const EmojiTextInputField: FC<
  OmitUnion<ComponentPropsWithoutRef<'input'>, EmojiInputProps>
> = ({
  onChange,
  value,
  label,
  hint,
  hasError,
  maxLength,
  recommended,
  disabled,
  ...otherProps
}) => {
  const inputRef = useRef<HTMLInputElement>(null);

  const wrapperProps = {
    label,
    hint,
    hasError,
    maxLength,
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
  recommended = false,
  disabled,
  hint,
  hasError,
  ...otherProps
}) => {
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  const wrapperProps = {
    label,
    hint,
    hasError,
    maxLength,
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
  maxLength,
  recommended = false,
  ...otherProps
}) => {
  const counterId = useId();

  const handlePickEmoji = useCallback(
    (emoji: string) => {
      onChange?.((prev) => {
        const position = inputRef.current?.selectionStart ?? prev.length;
        return insertEmojiAtPosition(prev, emoji, position);
      });
    },
    [onChange, inputRef],
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
          {maxLength && (
            <CharacterCounter
              currentString={value ?? ''}
              maxLength={maxLength}
              recommended={recommended}
              id={counterId}
            />
          )}
        </>
      )}
    </FormFieldWrapper>
  );
};
