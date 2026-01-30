import type { ComponentPropsWithoutRef, CSSProperties } from 'react';
import { forwardRef, useCallback, useEffect, useRef } from 'react';

import classes from './checkbox.module.scss';
import type { CommonFieldWrapperProps } from './form_field_wrapper';
import { FormFieldWrapper } from './form_field_wrapper';

type Props = Omit<ComponentPropsWithoutRef<'input'>, 'type'> & {
  size?: number;
  indeterminate?: boolean;
};

export const CheckboxField = forwardRef<
  HTMLInputElement,
  Props & CommonFieldWrapperProps
>(({ id, label, hint, hasError, required, ...otherProps }, ref) => (
  <FormFieldWrapper
    label={label}
    hint={hint}
    required={required}
    hasError={hasError}
    inputId={id}
    inputPlacement='inline-start'
  >
    {(inputProps) => <Checkbox {...otherProps} {...inputProps} ref={ref} />}
  </FormFieldWrapper>
));

CheckboxField.displayName = 'CheckboxField';

export const Checkbox = forwardRef<HTMLInputElement, Props>(
  ({ className, size, indeterminate, ...otherProps }, ref) => {
    const inputRef = useRef<HTMLInputElement | null>(null);

    const handleRef = useCallback(
      (element: HTMLInputElement | null) => {
        inputRef.current = element;
        if (typeof ref === 'function') {
          ref(element);
        } else if (ref) {
          ref.current = element;
        }
      },
      [ref],
    );

    useEffect(() => {
      if (inputRef.current) {
        inputRef.current.indeterminate = indeterminate || false;
      }
    }, [indeterminate]);

    return (
      <input
        {...otherProps}
        type='checkbox'
        className={classes.checkbox}
        style={size ? ({ '--size': `${size}px` } as CSSProperties) : undefined}
        ref={handleRef}
      />
    );
  },
);

Checkbox.displayName = 'Checkbox';
