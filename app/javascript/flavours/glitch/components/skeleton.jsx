import React from 'react';
import PropTypes from 'prop-types';

const Skeleton = ({ width, height }) => <span className='skeleton' style={{ width, height }}>&zwnj;</span>;

Skeleton.propTypes = {
  width: PropTypes.oneOfType([PropTypes.number, PropTypes.string]),
  height: PropTypes.oneOfType([PropTypes.number, PropTypes.string]),
};

export default Skeleton;
