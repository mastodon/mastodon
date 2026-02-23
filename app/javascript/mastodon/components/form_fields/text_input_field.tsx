import type { ComponentPropsWithoutRef } from 'react';
import { forwardRef } from 'react';

import classNames from 'classnames';

import type { IconProp } from 'mastodon/components/icon';
import { Icon } from 'mastodon/components/icon';

import { FormFieldWrapper } from './form_field_wrapper';
import type { CommonFieldWrapperProps } from './form_field_wrapper';
import classes from './text_input.module.scss';

export interface TextInputProps extends ComponentPropsWithoutRef<'input'> {
  icon?: IconProp;
}

interface Props extends TextInputProps, CommonFieldWrapperProps {}

/**
 * A simple form field for single-line text.
 *
 * Accepts an optional `hint` and can be marked as required
 * or optional (by explicitly setting `required={false}`)
 */

export const TextInputField = forwardRef<HTMLInputElement, Props>(
  ({ id, label, hint, hasError, required, ...otherProps }, ref) => (
    <FormFieldWrapper
      label={label}
      hint={hint}
      required={required}
      hasError={hasError}
      inputId={id}
    >
      {(inputProps) => <TextInput {...otherProps} {...inputProps} ref={ref} />}
    </FormFieldWrapper>
  ),
);

TextInputField.displayName = 'TextInputField';

export const TextInput = forwardRef<HTMLInputElement, TextInputProps>(
  ({ type = 'text', icon, className, ...otherProps }, ref) => (
    <WrapFieldWithIcon icon={icon}>
      <input
        type={type}
        {...otherProps}
        className={classNames(className, classes.input)}
        ref={ref}
      />
    </WrapFieldWithIcon>
  ),
);

TextInput.displayName = 'TextInput';

const WrapFieldWithIcon: React.FC<{
  icon?: IconProp;
  children: React.ReactElement;
}> = ({ icon, children }) => {
  if (icon) {
    return (
      <div className={classes.iconWrapper}>
        <Icon icon={icon} id='input-icon' className={classes.icon} />
        {children}
      </div>
    );
  }

  return children;
};
