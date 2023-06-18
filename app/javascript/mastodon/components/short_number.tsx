import { memo } from 'react';

import { FormattedMessage, FormattedNumber } from 'react-intl';

import { toShortNumber, pluralReady, DECIMAL_UNITS } from '../utils/numbers';

/**
 * Custom renderer for numbers
 * @param {JSX.Element} displayNumber Number to display
 * @param {number} pluralReady Number used for pluralization
 * @returns {JSX.Element} Final render of number
 */
interface ShortNumberRenderer {
  (
    displayNumber: JSX.Element, // Number to display
    pluralReady: number // Number used for pluralization
  ): JSX.Element; // Final render of number
}

/**
 * Component that renders short big number to a shorter version
 * @param {ShortNumberProps} props  Props for the component
 * @param {number} props.value value Number to display in short variant
 * @param {ShortNumberRenderer} [props.renderer]
 * Custom renderer for numbers, provided as a prop. If another renderer
 * passed as a child of this component, this prop won't be used.
 * @param {ShortNumberRenderer} [props.children]
 * Custom renderer for numbers, provided as a child. If another renderer
 * passed as a prop of this component, this one will be used instead.
 * @returns {JSX.Element} - Rendered number.
 */
interface ShortNumberProps {
  value: number;
  renderer?: ShortNumberRenderer;
  children?: ShortNumberRenderer;
}
export const ShortNumberRenderer: React.FC<ShortNumberProps> = ({
  value,
  renderer,
  children,
}): JSX.Element => {
  const shortNumber = toShortNumber(value);
  const [, division] = shortNumber;

  if (children != null && renderer != null) {
    console.warn(
      'Both renderer prop and renderer as a child provided. This is a mistake and you really should fix that. Only renderer passed as a child will be used.'
    );
  }

  const customRenderer = children != null ? children : renderer || null;

  const displayNumber = <ShortNumberCounter value={shortNumber} />;

  return customRenderer != null
    ? customRenderer(displayNumber, pluralReady(value, division))
    : displayNumber;
};
export const ShortNumber = memo(ShortNumberRenderer);

/**
 * Renders short number into corresponding localizable react fragment
 * @param {ShortNumberCounterProps} props Props for the component
 * @returns {JSX.Element} FormattedMessage ready to be embedded in code
 */
interface ShortNumberCounterProps {
  value: number[];
}
const ShortNumberCounter: React.FC<ShortNumberCounterProps> = ({ value }) => {
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

export default memo(ShortNumber);
