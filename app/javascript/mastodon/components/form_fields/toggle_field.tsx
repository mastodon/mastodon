import type { ComponentPropsWithoutRef, CSSProperties } from 'react';
import { forwardRef } from 'react';

import classNames from 'classnames';

import classes from './toggle.module.css';
import type { CommonFieldWrapperProps } from './wrapper';
import { FormFieldWrapper } from './wrapper';

type Props = Omit<ComponentPropsWithoutRef<'input'>, 'type'> & {
  size?: number;
};

export const ToggleField = forwardRef<
  HTMLInputElement,
  Props & CommonFieldWrapperProps
>(({ id, label, hint, hasError, required, ...otherProps }, ref) => (
  <FormFieldWrapper
    label={label}
    hint={hint}
    required={required}
    hasError={hasError}
    inputId={id}
  >
    {(inputProps) => (
      <PlainToggleField {...otherProps} {...inputProps} ref={ref} />
    )}
  </FormFieldWrapper>
));

ToggleField.displayName = 'ToggleField';

export const PlainToggleField = forwardRef<HTMLInputElement, Props>(
  ({ className, size, ...otherProps }, ref) => (
    <>
      <input
        {...otherProps}
        type='checkbox'
        className={classes.input}
        ref={ref}
      />
      <span
        className={classNames(classes.toggle, className)}
        style={
          { '--diameter': size ? `${size}px` : undefined } as CSSProperties
        }
        hidden
      />
    </>
  ),
);
PlainToggleField.displayName = 'PlainToggleField';
