import { memo } from 'react';

import { toShortNumber, pluralReady } from '../utils/numbers';

import { GenericCounterRenderer } from './counters';

type ShortNumberRenderer = (
  displayNumber: JSX.Element,
  pluralReady: number,
) => JSX.Element;

interface ShortNumberProps {
  value: number;
  renderer?: ShortNumberRenderer;
  children?: never;
}

export const ShortNumberRenderer: React.FC<ShortNumberProps> = ({
  value,
  renderer,
}) => {
  const shortNumber = toShortNumber(value);
  const [, division] = shortNumber;
  const displayNumber = <GenericCounterRenderer value={shortNumber} />;

  return (
    renderer?.(displayNumber, pluralReady(value, division)) ?? displayNumber
  );
};
export const ShortNumber = memo(ShortNumberRenderer);
