import type { ComponentPropsWithRef } from 'react';

import classNames from 'classnames';

import type { CommonFieldWrapperProps } from './form_field_wrapper';
import { FormFieldWrapper } from './form_field_wrapper';
import classes from './toggle.module.css';

type Props = Omit<ComponentPropsWithRef<'input'>, 'type' | 'size'> & {
  size?: 'sm' | 'lg';
};

export const ToggleField: React.FC<Props & CommonFieldWrapperProps> = ({
  id,
  label,
  hint,
  status,
  required,
  wrapperClassName,
  ...otherProps
}) => (
  <FormFieldWrapper
    label={label}
    hint={hint}
    required={required}
    status={status}
    inputId={id}
    inputPlacement='inline-end'
    className={wrapperClassName}
  >
    {(inputProps) => <Toggle {...otherProps} {...inputProps} />}
  </FormFieldWrapper>
);

ToggleField.displayName = 'ToggleField';

export const Toggle: React.FC<Props> = ({
  className,
  size = 'lg',
  ...otherProps
}) => (
  <span
    className={classNames(
      classes.wrapper,
      size === 'sm' && classes.small,
      className,
    )}
  >
    <input {...otherProps} type='checkbox' className={classes.input} />
    <span className={classes.toggle} hidden />
  </span>
);
