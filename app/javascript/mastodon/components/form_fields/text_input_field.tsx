import type { ComponentPropsWithoutRef } from 'react';
import { forwardRef } from 'react';

import { FormFieldWrapper } from './wrapper';
import type { CommonFieldWrapperProps } from './wrapper';

interface Props
  extends ComponentPropsWithoutRef<'input'>, CommonFieldWrapperProps {}

/**
 * A simple form field for single-line text.
 *
 * Accepts an optional `hint` and can be marked as required
 * or optional (by explicitly setting `required={false}`)
 */

export const TextInputField = forwardRef<HTMLInputElement, Props>(
  (
    { id, label, hint, hasError, required, type = 'text', ...otherProps },
    ref,
  ) => (
    <FormFieldWrapper
      label={label}
      hint={hint}
      required={required}
      hasError={hasError}
      inputId={id}
    >
      {(inputProps) => (
        <input type={type} {...otherProps} {...inputProps} ref={ref} />
      )}
    </FormFieldWrapper>
  ),
);

TextInputField.displayName = 'TextInputField';
