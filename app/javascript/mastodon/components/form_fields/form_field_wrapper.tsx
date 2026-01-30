/* eslint-disable @typescript-eslint/prefer-nullish-coalescing */

import type { ReactNode, FC } from 'react';
import { useContext, useId } from 'react';

import { FormattedMessage } from 'react-intl';

import { FieldsetNameContext } from './fieldset';
import classes from './form_field_wrapper.module.scss';

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
  inputPlacement?: 'inline-start' | 'inline-end';
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
  inputPlacement,
  children,
}) => {
  const uniqueId = useId();
  const inputId = inputIdProp || `${uniqueId}-input`;
  const hintId = `${inputIdProp || uniqueId}-hint`;
  const hasHint = !!hint;

  const hasParentFieldset = !!useContext(FieldsetNameContext);

  const inputProps: InputProps = {
    required,
    id: inputId,
  };
  if (hasHint) {
    inputProps['aria-describedby'] = hintId;
  }

  const input = (
    <div className={classes.inputWrapper}>{children(inputProps)}</div>
  );

  return (
    <div
      className={classes.wrapper}
      data-has-error={hasError}
      data-input-placement={inputPlacement}
    >
      {inputPlacement === 'inline-start' && input}

      <div className={classes.labelWrapper}>
        <label
          htmlFor={inputId}
          className={classes.label}
          data-has-parent-fieldset={hasParentFieldset}
        >
          {label}
          {required !== undefined && <RequiredMark required={required} />}
        </label>

        {hasHint && (
          <span className={classes.hint} id={hintId}>
            {hint}
          </span>
        )}
      </div>

      {inputPlacement !== 'inline-start' && input}
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
