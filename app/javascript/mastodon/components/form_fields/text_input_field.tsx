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
  iconClassName?: string;
}

interface Props extends TextInputProps, CommonFieldWrapperProps {}

/**
 * A simple form field for single-line text.
 *
 * Accepts an optional `hint` and can be marked as required
 * or optional (by explicitly setting `required={false}`)
 */

export const TextInputField = forwardRef<HTMLInputElement, Props>(
  (
    { id, label, hint, status, required, wrapperClassName, ...otherProps },
    ref,
  ) => (
    <FormFieldWrapper
      label={label}
      hint={hint}
      required={required}
      status={status}
      inputId={id}
      className={wrapperClassName}
    >
      {(inputProps) => <TextInput {...otherProps} {...inputProps} ref={ref} />}
    </FormFieldWrapper>
  ),
);

TextInputField.displayName = 'TextInputField';

export const TextInput = forwardRef<HTMLInputElement, TextInputProps>(
  (
    {
      type = 'text',
      icon,
      iconClassName,
      className,
      autoComplete,
      ...otherProps
    },
    ref,
  ) => (
    <WrapFieldWithIcon icon={icon} iconClassName={iconClassName}>
      <input
        type={type}
        {...otherProps}
        autoComplete={autoComplete}
        className={classNames(className, classes.input)}
        ref={ref}
        // Disable password manager autocomplete if normal autocomplete is disabled.
        {...(autoComplete === 'off'
          ? {
              'data-1p-ignore': true,
              'data-lpignore': 'true',
              'data-protonpass-ignore': 'true',
            }
          : null)}
      />
    </WrapFieldWithIcon>
  ),
);

TextInput.displayName = 'TextInput';

const WrapFieldWithIcon: React.FC<{
  icon?: IconProp;
  iconClassName?: string;
  children: React.ReactElement;
}> = ({ icon, iconClassName, children }) => {
  if (icon) {
    return (
      <div className={classNames(classes.iconWrapper, iconClassName)}>
        <Icon icon={icon} id='input-icon' className={classes.icon} />
        {children}
      </div>
    );
  }

  return children;
};
