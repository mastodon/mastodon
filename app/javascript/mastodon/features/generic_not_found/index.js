import React from 'react';
import Column from '../ui/components/column';
import MissingIndicator from '../../components/missing_indicator';

const GenericNotFound = () => (
  <Column>
    <MissingIndicator fullPage />
  </Column>
);

export default GenericNotFound;
