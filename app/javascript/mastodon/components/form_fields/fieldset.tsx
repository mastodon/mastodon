/* eslint-disable @typescript-eslint/prefer-nullish-coalescing */

import type { ReactNode, FC } from 'react';
import { createContext, useId } from 'react';

import classes from './fieldset.module.scss';
import formFieldWrapperClasses from './form_field_wrapper.module.scss';

interface FieldsetProps {
  legend: ReactNode;
  hint?: ReactNode;
  name?: string;
  hasError?: boolean;
  layout?: 'vertical' | 'horizontal';
  children: ReactNode;
}

export const FieldsetNameContext = createContext<string | undefined>(undefined);

/**
 * A fieldset suitable for wrapping a group of checkboxes,
 * radio buttons, or other grouped form controls.
 */

export const Fieldset: FC<FieldsetProps> = ({
  legend,
  hint,
  name,
  hasError,
  layout,
  children,
}) => {
  const uniqueId = useId();
  const labelId = `${uniqueId}-label`;
  const hintId = `${uniqueId}-hint`;
  const fieldsetName = name || `${uniqueId}-fieldset-name`;
  const hasHint = !!hint;

  return (
    <fieldset
      className={classes.fieldset}
      data-has-error={hasError}
      aria-labelledby={labelId}
      aria-describedby={hintId}
    >
      <div className={formFieldWrapperClasses.labelWrapper}>
        <div id={labelId} className={formFieldWrapperClasses.label}>
          {legend}
        </div>
        {hasHint && (
          <p id={hintId} className={formFieldWrapperClasses.hint}>
            {hint}
          </p>
        )}
      </div>

      <div className={classes.fieldsWrapper} data-layout={layout}>
        <FieldsetNameContext.Provider value={fieldsetName}>
          {children}
        </FieldsetNameContext.Provider>
      </div>
    </fieldset>
  );
};
