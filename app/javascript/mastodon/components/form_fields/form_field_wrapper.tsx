/* eslint-disable @typescript-eslint/prefer-nullish-coalescing */

import type { ReactNode, FC } from 'react';
import { useContext, useId } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { A11yLiveRegion } from 'mastodon/components/a11y_live_region';
import { CalloutInline } from 'mastodon/components/callout_inline';

import { FieldsetNameContext } from './fieldset';
import classes from './form_field_wrapper.module.scss';

export interface InputProps {
  id: string;
  required?: boolean;
  'aria-describedby'?: string;
}

export interface FieldStatus {
  variant: 'error' | 'warning' | 'info' | 'success';
  message?: string;
}

interface FieldWrapperProps {
  label: ReactNode;
  hint?: ReactNode;
  required?: boolean;
  status?: FieldStatus['variant'] | FieldStatus | null;
  inputId?: string;
  describedById?: string;
  inputPlacement?: 'inline-start' | 'inline-end';
  children: (inputProps: InputProps) => ReactNode;
  className?: string;
}

/**
 * These types can be extended when creating individual field components.
 */
export type CommonFieldWrapperProps = Pick<
  FieldWrapperProps,
  'label' | 'hint' | 'status'
> & { wrapperClassName?: string };

/**
 * A simple form field wrapper for adding a label and hint to enclosed components.
 * Accepts an optional `hint` and can be marked as required
 * or optional (by explicitly setting `required={false}`)
 */

export const FormFieldWrapper: FC<FieldWrapperProps> = ({
  inputId: inputIdProp,
  label,
  hint,
  describedById,
  required,
  status,
  inputPlacement,
  children,
  className,
}) => {
  const uniqueId = useId();
  const inputId = inputIdProp || `${uniqueId}-input`;
  const statusId = `${inputIdProp || uniqueId}-status`;
  const hintId = `${inputIdProp || uniqueId}-hint`;
  const hasHint = !!hint;
  const fieldStatus = getFieldStatus(status);
  const hasStatusMessage = !!fieldStatus?.message;

  const hasParentFieldset = !!useContext(FieldsetNameContext);

  const descriptionIds =
    [hasHint ? hintId : '', hasStatusMessage ? statusId : '', describedById]
      .filter((id) => !!id)
      .join(' ') || undefined;

  const inputProps: InputProps = {
    required,
    id: inputId,
    'aria-describedby': descriptionIds,
  };

  const input = (
    <div className={classes.inputWrapper}>{children(inputProps)}</div>
  );

  return (
    <div
      className={classNames(classes.wrapper, className)}
      data-has-error={fieldStatus?.variant === 'error'}
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

      {/* Live region must be rendered even when empty */}
      <A11yLiveRegion className={classes.status} id={statusId}>
        {hasStatusMessage && <CalloutInline {...fieldStatus} />}
      </A11yLiveRegion>
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

export function getFieldStatus(status: FieldWrapperProps['status']) {
  if (!status) {
    return null;
  }

  if (typeof status === 'string') {
    const fieldStatus: FieldStatus = {
      variant: status,
      message: '',
    };
    return fieldStatus;
  }

  return status;
}
