/* eslint-disable @typescript-eslint/prefer-nullish-coalescing */

import type { ReactNode, FC } from 'react';
import { createContext, useId } from 'react';

import { A11yLiveRegion } from 'mastodon/components/a11y_live_region';
import { CalloutInline } from 'mastodon/components/callout_inline';

import classes from './fieldset.module.scss';
import type { FieldStatus } from './form_field_wrapper';
import { getFieldStatus } from './form_field_wrapper';
import formFieldWrapperClasses from './form_field_wrapper.module.scss';

interface FieldsetProps {
  legend: ReactNode;
  hint?: ReactNode;
  name?: string;
  status?: FieldStatus | FieldStatus['variant'];
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
  status,
  layout,
  children,
}) => {
  const uniqueId = useId();
  const labelId = `${uniqueId}-label`;
  const hintId = `${uniqueId}-hint`;
  const statusId = `${uniqueId}-status`;
  const fieldsetName = name || `${uniqueId}-fieldset-name`;
  const hasHint = !!hint;

  const fieldStatus = getFieldStatus(status);
  const hasStatusMessage = !!fieldStatus?.message;

  const descriptionIds = [
    hasHint ? hintId : '',
    hasStatusMessage ? statusId : '',
  ]
    .filter((id) => !!id)
    .join(' ');

  return (
    <fieldset
      className={classes.fieldset}
      data-has-error={status === 'error'}
      aria-labelledby={labelId}
      aria-describedby={descriptionIds}
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

      {/* Live region must be rendered even when empty */}
      <A11yLiveRegion className={classes.status} id={statusId}>
        {hasStatusMessage && <CalloutInline {...fieldStatus} />}
      </A11yLiveRegion>
    </fieldset>
  );
};
