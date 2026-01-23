import type { ComponentPropsWithoutRef, CSSProperties } from 'react';
import { forwardRef } from 'react';

import classNames from 'classnames';

import classes from './toggle.module.css';
import type { CommonFieldWrapperProps } from './wrapper';
import { FormFieldWrapper } from './wrapper';

type Props = Omit<ComponentPropsWithoutRef<'input'>, 'type'> &
  CommonFieldWrapperProps & { size?: number };

export const ToggleField = forwardRef<HTMLInputElement, Props>(
  (
    { id, label, hint, hasError, required, className, size, ...otherProps },
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
        <>
          <input
            {...otherProps}
            {...inputProps}
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
      )}
    </FormFieldWrapper>
  ),
);

ToggleField.displayName = 'ToggleField';
