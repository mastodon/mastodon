import type { ComponentPropsWithoutRef, ReactNode } from 'react';
import { forwardRef } from 'react';

import { FormFieldWrapper } from './wrapper';

interface Props extends ComponentPropsWithoutRef<'select'> {
  label: ReactNode;
  hint?: ReactNode;
}

/**
 * A simple form field for single-item selections.
 * Provide selectable items via nested `<option>` elements.
 *
 * Accepts an optional `hint` and can be marked as required
 * or optional (by explicitly setting `required={false}`)
 */

export const SelectField = forwardRef<HTMLSelectElement, Props>(
  ({ id, label, hint, required, children, ...otherProps }, ref) => (
    <FormFieldWrapper
      label={label}
      hint={hint}
      required={required}
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
