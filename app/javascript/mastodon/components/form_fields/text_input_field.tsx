import type { ComponentPropsWithoutRef } from 'react';
import { forwardRef } from 'react';

import classNames from 'classnames';

import { FormFieldWrapper } from './form_field_wrapper';
import type { CommonFieldWrapperProps } from './form_field_wrapper';
import classes from './text_input.module.scss';

interface Props
  extends ComponentPropsWithoutRef<'input'>, CommonFieldWrapperProps {}

/**
 * A simple form field for single-line text.
 *
 * Accepts an optional `hint` and can be marked as required
 * or optional (by explicitly setting `required={false}`)
 */

export const TextInputField = forwardRef<HTMLInputElement, Props>(
  ({ id, label, hint, hasError, required, ...otherProps }, ref) => (
    <FormFieldWrapper
      label={label}
      hint={hint}
      required={required}
      hasError={hasError}
      inputId={id}
    >
      {(inputProps) => <TextInput {...otherProps} {...inputProps} ref={ref} />}
    </FormFieldWrapper>
  ),
);

TextInputField.displayName = 'TextInputField';

export const TextInput = forwardRef<
  HTMLInputElement,
  ComponentPropsWithoutRef<'input'>
>(({ type = 'text', className, ...otherProps }, ref) => (
  <input
    type={type}
    {...otherProps}
    className={classNames(className, classes.input)}
    ref={ref}
  />
));

TextInput.displayName = 'TextInput';
