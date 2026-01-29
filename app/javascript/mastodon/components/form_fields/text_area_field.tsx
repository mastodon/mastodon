import type { ComponentPropsWithoutRef } from 'react';
import { forwardRef } from 'react';

import { FormFieldWrapper } from './form_field_wrapper';
import type { CommonFieldWrapperProps } from './form_field_wrapper';

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
      {(inputProps) => <textarea {...otherProps} {...inputProps} ref={ref} />}
    </FormFieldWrapper>
  ),
);

TextAreaField.displayName = 'TextAreaField';
