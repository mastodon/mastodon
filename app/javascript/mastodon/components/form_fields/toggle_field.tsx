import type { ComponentPropsWithoutRef, CSSProperties } from 'react';
import { forwardRef } from 'react';

import classNames from 'classnames';

import type { CommonFieldWrapperProps } from './form_field_wrapper';
import { FormFieldWrapper } from './form_field_wrapper';
import classes from './toggle.module.css';

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
    inputPlacement='inline-end'
  >
    {(inputProps) => <Toggle {...otherProps} {...inputProps} ref={ref} />}
  </FormFieldWrapper>
));

ToggleField.displayName = 'ToggleField';

export const Toggle = forwardRef<HTMLInputElement, Props>(
  ({ className, size, ...otherProps }, ref) => (
    <span className={classes.wrapper}>
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
    </span>
  ),
);
Toggle.displayName = 'Toggle';
