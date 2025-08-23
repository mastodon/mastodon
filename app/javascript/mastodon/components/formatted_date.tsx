import type { ComponentProps } from 'react';

import { FormattedDate } from 'react-intl';

import { timeZone } from 'mastodon/initial_state';

export const FormattedDateWrapper = (
  props: ComponentProps<typeof FormattedDate> & { className?: string },
) => (
  <FormattedDate {...props} timeZone={timeZone}>
    {(date) => (
      <time dateTime={tryIsoString(props.value)} className={props.className}>
        {date}
      </time>
    )}
  </FormattedDate>
);

const tryIsoString = (date?: string | number | Date): string => {
  if (!date) {
    return '';
  }
  try {
    return new Date(date).toISOString();
  } catch {
    return date.toString();
  }
};
