import { memo } from 'react';
import type { JSX } from 'react';

import { FormattedMessage, FormattedNumber } from 'react-intl';

import { toShortNumber, pluralReady, DECIMAL_UNITS } from '../utils/numbers';

type ShortNumberRenderer = (
  displayNumber: JSX.Element,
  pluralReady: number,
) => JSX.Element;

interface ShortNumberProps {
  value: number;
  renderer?: ShortNumberRenderer;
  children?: ShortNumberRenderer;
}

export const ShortNumberRenderer: React.FC<ShortNumberProps> = ({
  value,
  renderer,
  children,
}) => {
  const shortNumber = toShortNumber(value);
  const [, division] = shortNumber;

  if (children && renderer) {
    console.warn(
      'Both renderer prop and renderer as a child provided. This is a mistake and you really should fix that. Only renderer passed as a child will be used.',
    );
  }

  const customRenderer = children ?? renderer ?? null;

  const displayNumber = <ShortNumberCounter value={shortNumber} />;

  return (
    customRenderer?.(displayNumber, pluralReady(value, division)) ??
    displayNumber
  );
};
export const ShortNumber = memo(ShortNumberRenderer);

interface ShortNumberCounterProps {
  value: number[];
}
const ShortNumberCounter: React.FC<ShortNumberCounterProps> = ({ value }) => {
  const [rawNumber, unit, maxFractionDigits = 0] = value;

  const count = (
    <FormattedNumber
      value={rawNumber ?? 0}
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
