import { memo } from 'react';

import { toShortNumber } from '../utils/numbers';

import { GenericCounterRenderer } from './counters';

interface GenericCounterProps {
  value: number;
  children?: never;
}

const _GenericCounter: React.FC<GenericCounterProps> = ({ value }) => {
  const shortNumber = toShortNumber(value);
  return <GenericCounterRenderer value={shortNumber} />;
};
export const GenericCounter = memo(_GenericCounter);
