import type { ComponentPropsWithoutRef, ReactNode } from 'react';
import { forwardRef } from 'react';

import { FormFieldWrapper } from './wrapper';

interface Props extends ComponentPropsWithoutRef<'input'> {
  label: ReactNode;
  hint?: ReactNode;
  type?: string;
}

/**
 * A simple form field for single-line text.
 *
 * Accepts an optional `hint` and can be marked as required
 * or optional (by explicitly setting `required={false}`)
 */

export const TextInputField = forwardRef<HTMLInputElement, Props>(
  ({ id, label, hint, required, type = 'text', ...otherProps }, ref) => (
    <FormFieldWrapper
      label={label}
      hint={hint}
      required={required}
      inputId={id}
    >
      {(inputProps) => (
        <input type={type} {...otherProps} {...inputProps} ref={ref} />
      )}
    </FormFieldWrapper>
  ),
);

TextInputField.displayName = 'TextInputField';
