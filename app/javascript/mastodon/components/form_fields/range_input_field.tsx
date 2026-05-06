import type { ComponentPropsWithoutRef } from 'react';
import { forwardRef, useId } from 'react';

import classNames from 'classnames';

import { FormFieldWrapper } from './form_field_wrapper';
import type { CommonFieldWrapperProps } from './form_field_wrapper';
import classes from './range_input.module.scss';

export type RangeInputProps = Omit<
  ComponentPropsWithoutRef<'input'>,
  'type' | 'list'
> & {
  markers?: { value: number; label: string }[] | number[];
};

interface Props extends RangeInputProps, CommonFieldWrapperProps {
  inputPlacement?: 'inline-start' | 'inline-end'; // TODO: Move this to the common field wrapper props for other fields.
}

/**
 * A simple form field for single-line text.
 *
 * Accepts an optional `hint` and can be marked as required
 * or optional (by explicitly setting `required={false}`)
 */

export const RangeInputField = forwardRef<HTMLInputElement, Props>(
  (
    {
      id,
      label,
      hint,
      status,
      required,
      wrapperClassName,
      inputPlacement,
      ...otherProps
    },
    ref,
  ) => (
    <FormFieldWrapper
      label={label}
      hint={hint}
      required={required}
      status={status}
      inputId={id}
      inputPlacement={inputPlacement}
      className={wrapperClassName}
    >
      {(inputProps) => <RangeInput {...otherProps} {...inputProps} ref={ref} />}
    </FormFieldWrapper>
  ),
);

RangeInputField.displayName = 'RangeInputField';

export const RangeInput = forwardRef<HTMLInputElement, RangeInputProps>(
  ({ className, markers, id, ...otherProps }, ref) => {
    const markersId = useId();

    if (!markers) {
      return (
        <input
          {...otherProps}
          type='range'
          className={classNames(className, classes.input)}
          ref={ref}
        />
      );
    }
    return (
      <>
        <input
          {...otherProps}
          type='range'
          className={classNames(className, classes.input)}
          ref={ref}
          list={markersId}
        />
        <datalist id={markersId} className={classes.markers}>
          {markers.map((marker) => {
            const value = typeof marker === 'number' ? marker : marker.value;
            return (
              <option
                key={value}
                value={value}
                label={typeof marker !== 'number' ? marker.label : undefined}
              />
            );
          })}
        </datalist>
      </>
    );
  },
);

RangeInput.displayName = 'RangeInput';
