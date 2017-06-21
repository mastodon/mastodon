import React from 'react';

import Column from '../../../components/column';
import ColumnHeader from '../../../components/column_header';

const ColumnLoading = () => (
  <Column>
    <ColumnHeader icon=' ' title='' multiColumn={false} />
    <div className='scrollable' />
  </Column>
);

export default ColumnLoading;
