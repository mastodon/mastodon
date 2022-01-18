import React from 'react';
import PropTypes from 'prop-types';

const Skeleton = ({ width, height }) => <span className='skeleton' style={{ width, height }}>&zwnj;</span>;

Skeleton.propTypes = {
  width: PropTypes.number,
  height: PropTypes.number,
};

export default Skeleton;
