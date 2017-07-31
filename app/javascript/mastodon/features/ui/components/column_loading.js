import React from 'react';
import PropTypes from 'prop-types';

import Column from '../../../components/column';
import ColumnHeader from '../../../components/column_header';

const ColumnLoading = ({ title = '', icon = ' ' }) => (
  <Column>
    <ColumnHeader icon={icon} title={title} multiColumn={false} focusable={false} />
    <div className='scrollable' />
  </Column>
);

ColumnLoading.propTypes = {
  title: PropTypes.node,
  icon: PropTypes.string,
};

export default ColumnLoading;
