import type { ComponentPropsWithoutRef } from 'react';
import { forwardRef, useCallback } from 'react';

import classNames from 'classnames';

import { FormFieldWrapper } from './form_field_wrapper';
import type { CommonFieldWrapperProps } from './form_field_wrapper';
import classes from './text_input.module.scss';

interface Props
  extends ComponentPropsWithoutRef<'textarea'>, CommonFieldWrapperProps {}

/**
 * A simple form field for multi-line text.
 *
 * Accepts an optional `hint` and can be marked as required
 * or optional (by explicitly setting `required={false}`)
 */

export const TextAreaField = forwardRef<HTMLTextAreaElement, Props>(
  ({ id, label, hint, required, hasError, ...otherProps }, ref) => (
    <FormFieldWrapper
      label={label}
      hint={hint}
      required={required}
      hasError={hasError}
      inputId={id}
    >
      {(inputProps) => <TextArea {...otherProps} {...inputProps} ref={ref} />}
    </FormFieldWrapper>
  ),
);

TextAreaField.displayName = 'TextAreaField';

export const TextArea = forwardRef<
  HTMLTextAreaElement,
  ComponentPropsWithoutRef<'textarea'>
>(({ className, onKeyDown, ...otherProps }, ref) => {
  const handleSubmitHotkey = useCallback(
    (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
      onKeyDown?.(e);
      if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
        const targetForm = e.currentTarget.form;
        targetForm?.requestSubmit();
      }
    },
    [onKeyDown],
  );

  return (
    <textarea
      {...otherProps}
      onKeyDown={handleSubmitHotkey}
      className={classNames(className, classes.input)}
      ref={ref}
    />
  );
});

TextArea.displayName = 'TextArea';
