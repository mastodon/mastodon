import React from 'react';
import Column from 'flavours/glitch/features/ui/components/column';
import MissingIndicator from 'flavours/glitch/components/missing_indicator';

const GenericNotFound = () => (
  <Column>
    <MissingIndicator fullPage />
  </Column>
);

export default GenericNotFound;
