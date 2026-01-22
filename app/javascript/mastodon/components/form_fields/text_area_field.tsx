import type { ComponentPropsWithoutRef, ReactNode } from 'react';
import { forwardRef } from 'react';

import { FormFieldWrapper } from './wrapper';

interface Props extends ComponentPropsWithoutRef<'textarea'> {
  label: ReactNode;
  hint?: ReactNode;
}

/**
 * A simple form field for multi-line text.
 *
 * Accepts an optional `hint` and can be marked as required
 * or optional (by explicitly setting `required={false}`)
 */

export const TextAreaField = forwardRef<HTMLTextAreaElement, Props>(
  ({ id, label, hint, required, ...otherProps }, ref) => (
    <FormFieldWrapper
      label={label}
      hint={hint}
      required={required}
      inputId={id}
    >
      {(inputProps) => <textarea {...otherProps} {...inputProps} ref={ref} />}
    </FormFieldWrapper>
  ),
);

TextAreaField.displayName = 'TextAreaField';
