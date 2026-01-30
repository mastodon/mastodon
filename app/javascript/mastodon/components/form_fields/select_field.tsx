import type { ComponentPropsWithoutRef } from 'react';
import { forwardRef } from 'react';

import { FormFieldWrapper } from './form_field_wrapper';
import type { CommonFieldWrapperProps } from './form_field_wrapper';

interface Props
  extends ComponentPropsWithoutRef<'select'>, CommonFieldWrapperProps {}

/**
 * A simple form field for single-item selections.
 * Provide selectable items via nested `<option>` elements.
 *
 * Accepts an optional `hint` and can be marked as required
 * or optional (by explicitly setting `required={false}`)
 */

export const SelectField = forwardRef<HTMLSelectElement, Props>(
  ({ id, label, hint, required, hasError, children, ...otherProps }, ref) => (
    <FormFieldWrapper
      label={label}
      hint={hint}
      required={required}
      hasError={hasError}
      inputId={id}
    >
      {(inputProps) => (
        <div className='select-wrapper'>
          <select {...otherProps} {...inputProps} ref={ref}>
            {children}
          </select>
        </div>
      )}
    </FormFieldWrapper>
  ),
);

SelectField.displayName = 'SelectField';
