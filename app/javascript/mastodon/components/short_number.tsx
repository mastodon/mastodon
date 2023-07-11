import { memo } from 'react';

import { toShortNumber } from '../utils/numbers';

import { GenericCounterRenderer } from './counters';

interface ShortNumberProps {
  value: number;
  children?: never;
}

export const ShortNumberRenderer: React.FC<ShortNumberProps> = ({ value }) => {
  const shortNumber = toShortNumber(value);
  return <GenericCounterRenderer value={shortNumber} />;
};
export const ShortNumber = memo(ShortNumberRenderer);
