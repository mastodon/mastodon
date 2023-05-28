import PropTypes from 'prop-types';
import { memo } from 'react';

import { FormattedMessage, FormattedNumber } from 'react-intl';

import { toShortNumber, pluralReady, DECIMAL_UNITS } from '../utils/numbers';
// @ts-check

/**
 * @callback ShortNumberRenderer
 * @param {JSX.Element} displayNumber Number to display
 * @param {number} pluralReady Number used for pluralization
 * @returns {JSX.Element} Final render of number
 */

/**
 * @typedef {object} ShortNumberProps
 * @property {number} value Number to display in short variant
 * @property {ShortNumberRenderer} [renderer]
 * Custom renderer for numbers, provided as a prop. If another renderer
 * passed as a child of this component, this prop won't be used.
 * @property {ShortNumberRenderer} [children]
 * Custom renderer for numbers, provided as a child. If another renderer
 * passed as a prop of this component, this one will be used instead.
 */

/**
 * Component that renders short big number to a shorter version
 * @param {ShortNumberProps} param0 Props for the component
 * @returns {JSX.Element} Rendered number
 */
function ShortNumber({ value, renderer, children }) {
  const shortNumber = toShortNumber(value);
  const [, division] = shortNumber;

  if (children != null && renderer != null) {
    console.warn('Both renderer prop and renderer as a child provided. This is a mistake and you really should fix that. Only renderer passed as a child will be used.');
  }

  const customRenderer = children != null ? children : renderer;

  const displayNumber = <ShortNumberCounter value={shortNumber} />;

  return customRenderer != null
    ? customRenderer(displayNumber, pluralReady(value, division))
    : displayNumber;
}

ShortNumber.propTypes = {
  value: PropTypes.number.isRequired,
  renderer: PropTypes.func,
  children: PropTypes.func,
};

/**
 * @typedef {object} ShortNumberCounterProps
 * @property {import('../utils/number').ShortNumber} value Short number
 */

/**
 * Renders short number into corresponding localizable react fragment
 * @param {ShortNumberCounterProps} param0 Props for the component
 * @returns {JSX.Element} FormattedMessage ready to be embedded in code
 */
function ShortNumberCounter({ value }) {
  const [rawNumber, unit, maxFractionDigits = 0] = value;

  const count = (
    <FormattedNumber
      value={rawNumber}
      maximumFractionDigits={maxFractionDigits}
    />
  );

  let values = { count, rawNumber };

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
  default: return count;
  }
}

ShortNumberCounter.propTypes = {
  value: PropTypes.arrayOf(PropTypes.number),
};

export default memo(ShortNumber);
