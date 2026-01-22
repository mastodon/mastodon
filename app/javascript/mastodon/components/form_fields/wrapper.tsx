/* eslint-disable @typescript-eslint/prefer-nullish-coalescing */

import type { ReactNode, FC } from 'react';
import { useId } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

interface InputProps {
  id: string;
  required?: boolean;
  'aria-describedby'?: string;
}

interface FieldWrapperProps {
  label: ReactNode;
  hint?: ReactNode;
  required?: boolean;
  hasError?: boolean;
  inputId?: string;
  children: (inputProps: InputProps) => ReactNode;
}

/**
 * These types can be extended when creating individual field components.
 */
export type CommonFieldWrapperProps = Pick<
  FieldWrapperProps,
  'label' | 'hint' | 'hasError'
>;

/**
 * A simple form field wrapper for adding a label and hint to enclosed components.
 * Accepts an optional `hint` and can be marked as required
 * or optional (by explicitly setting `required={false}`)
 */

export const FormFieldWrapper: FC<FieldWrapperProps> = ({
  inputId: inputIdProp,
  label,
  hint,
  required,
  hasError,
  children,
}) => {
  const uniqueId = useId();
  const inputId = inputIdProp || `${uniqueId}-input`;
  const hintId = `${inputIdProp || uniqueId}-hint`;
  const hasHint = !!hint;

  const inputProps: InputProps = {
    required,
    id: inputId,
  };
  if (hasHint) {
    inputProps['aria-describedby'] = hintId;
  }

  return (
    <div
      className={classNames('input with_block_label', {
        field_with_errors: hasError,
      })}
    >
      <div className='label_input'>
        <label htmlFor={inputId}>
          {label}
          {required !== undefined && <RequiredMark required={required} />}
        </label>

        {hasHint && (
          <span className='hint' id={hintId}>
            {hint}
          </span>
        )}

        <div className='label_input__wrapper'>{children(inputProps)}</div>
      </div>
    </div>
  );
};

/**
 * If `required` is explicitly set to `false` rather than `undefined`,
 * the field will be visually marked as "optional".
 */

const RequiredMark: FC<{ required?: boolean }> = ({ required }) =>
  required ? (
    <>
      {' '}
      <abbr aria-hidden='true'>*</abbr>
    </>
  ) : (
    <>
      {' '}
      <FormattedMessage id='form_field.optional' defaultMessage='(optional)' />
    </>
  );
