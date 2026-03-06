import { forwardRef, useCallback, useRef } from 'react';

import { useIntl } from 'react-intl';

import classNames from 'classnames';

import { CopyIconButton } from 'mastodon/components/copy_icon_button';

import classes from './copy_link_field.module.scss';
import { FormFieldWrapper } from './form_field_wrapper';
import type { CommonFieldWrapperProps } from './form_field_wrapper';
import { TextInput } from './text_input_field';
import type { TextInputProps } from './text_input_field';

interface CopyLinkFieldProps extends CommonFieldWrapperProps, TextInputProps {
  value: string;
}

/**
 * A read-only text field with a button for copying the field value
 */

export const CopyLinkField = forwardRef<HTMLInputElement, CopyLinkFieldProps>(
  (
    { id, label, hint, hasError, value, required, className, ...otherProps },
    ref,
  ) => {
    const intl = useIntl();
    const inputRef = useRef<HTMLInputElement | null>();
    const handleFocus = useCallback(() => {
      inputRef.current?.select();
    }, []);

    const mergeRefs = useCallback(
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

    return (
      <FormFieldWrapper
        label={label}
        hint={hint}
        required={required}
        hasError={hasError}
        inputId={id}
      >
        {(inputProps) => (
          <div className={classes.wrapper}>
            <TextInput
              readOnly
              {...otherProps}
              {...inputProps}
              ref={mergeRefs}
              value={value}
              onFocus={handleFocus}
              className={classNames(className, classes.input)}
            />
            <CopyIconButton
              value={value}
              title={intl.formatMessage({
                id: 'copy_icon_button.copy_this_text',
                defaultMessage: 'Copy link to clipboard',
              })}
              className={classes.copyButton}
              aria-describedby={inputProps.id}
            />
          </div>
        )}
      </FormFieldWrapper>
    );
  },
);

CopyLinkField.displayName = 'CopyLinkField';
