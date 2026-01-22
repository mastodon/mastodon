/* eslint-disable @typescript-eslint/prefer-nullish-coalescing */

import type { ReactNode, FC } from 'react';
import { useId } from 'react';

import { FormattedMessage } from 'react-intl';

interface InputProps {
  id: string;
  required?: boolean;
  'aria-describedby'?: string;
}

interface Props {
  label: ReactNode;
  hint?: ReactNode;
  required?: boolean;
  inputId?: string;
  children: (inputProps: InputProps) => ReactNode;
}

/**
 * A simple form field wrapper for adding a label and hint to enclosed components.
 * Accepts an optional `hint` and can be marked as required
 * or optional (by explicitly setting `required={false}`)
 */

export const FormFieldWrapper: FC<Props> = ({
  inputId: inputIdProp,
  label,
  hint,
  required,
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
    <div className='input with_label'>
      <div className='label_input'>
        <label htmlFor={inputId}>
          {label}
          {required !== undefined && <RequiredMark required={required} />}
        </label>

        <div className='label_input__wrapper'>{children(inputProps)}</div>

        {hasHint && (
          <span className='hint' id={hintId}>
            {hint}
          </span>
        )}
      </div>
    </div>
  );
};

FormFieldWrapper.displayName = 'FormFieldWrapper';

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
