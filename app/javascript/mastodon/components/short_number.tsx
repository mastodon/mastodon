import type { ReactNode } from 'react';
import { memo } from 'react';

import { FormattedMessage, FormattedNumber } from 'react-intl';

import type { ShortNumber as ShortNumberType } from '../utils/numbers';
import { toShortNumber, pluralReady, DECIMAL_UNITS } from '../utils/numbers';

interface ShortNumberArgs {
  value: number;
  renderer: (displayNumber: ReactNode, pluralReady: number) => ReactNode;
}
const _ShortNumber = ({ value, renderer }: ShortNumberArgs): ReactNode => {
  const shortNumber = toShortNumber(value);
  const [, division] = shortNumber;

  const displayNumber = <ShortNumberCounter value={shortNumber} />;
  return renderer != null
    ? renderer(displayNumber, pluralReady(value, division))
    : displayNumber;
};

const ShortNumberCounter = ({ value }: { value: ShortNumberType }) => {
  const [rawNumber, unit, maxFractionDigits = 0] = value;

  const count = (
    <FormattedNumber
      value={rawNumber}
      maximumFractionDigits={maxFractionDigits}
    />
  );

  const values = { count, rawNumber };

  switch (unit) {
    case DECIMAL_UNITS.THOUSAND: {
      return (
        <FormattedMessage
          id='units.short.thousand'
          defaultMessage='{count}K'
          values={values}
        />
      );
    }
    case DECIMAL_UNITS.MILLION: {
      return (
        <FormattedMessage
          id='units.short.million'
          defaultMessage='{count}M'
          values={values}
        />
      );
    }
    case DECIMAL_UNITS.BILLION: {
      return (
        <FormattedMessage
          id='units.short.billion'
          defaultMessage='{count}B'
          values={values}
        />
      );
    }
    // Not sure if we should go farther - @Sasha-Sorokin
    default:
      return count;
  }
};

export const ShortNumber = memo(_ShortNumber);
