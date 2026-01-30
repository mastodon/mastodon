/* eslint-disable @typescript-eslint/prefer-nullish-coalescing */

import type { ComponentPropsWithoutRef, CSSProperties } from 'react';
import { forwardRef, useContext } from 'react';

import { FieldsetNameContext } from './fieldset';
import type { CommonFieldWrapperProps } from './form_field_wrapper';
import { FormFieldWrapper } from './form_field_wrapper';
import classes from './radio_button.module.scss';

type Props = Omit<ComponentPropsWithoutRef<'input'>, 'type'> & {
  size?: number;
};

export const RadioButtonField = forwardRef<
  HTMLInputElement,
  Props & CommonFieldWrapperProps
>(({ id, label, hint, hasError, required, ...otherProps }, ref) => {
  const fieldsetName = useContext(FieldsetNameContext);

  return (
    <FormFieldWrapper
      label={label}
      hint={hint}
      required={required}
      hasError={hasError}
      inputId={id}
      inputPlacement='inline-start'
    >
      {(inputProps) => (
        <RadioButton
          {...otherProps}
          {...inputProps}
          name={otherProps.name || fieldsetName}
          ref={ref}
        />
      )}
    </FormFieldWrapper>
  );
});

RadioButtonField.displayName = 'RadioButtonField';

export const RadioButton = forwardRef<HTMLInputElement, Props>(
  ({ className, size, ...otherProps }, ref) => (
    <input
      {...otherProps}
      type='radio'
      className={classes.radioButton}
      style={size ? ({ '--size': `${size}px` } as CSSProperties) : undefined}
      ref={ref}
    />
  ),
);

RadioButton.displayName = 'RadioButton';
