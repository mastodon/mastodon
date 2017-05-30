import React from 'react';
import { FormattedMessage } from 'react-intl';
import PropTypes from 'prop-types';

const LoadMore = ({ onClick }) => (
  <button className='load-more' onClick={onClick}>
    <FormattedMessage id='status.load_more' defaultMessage='Load more' />
  </button>
);

LoadMore.propTypes = {
  onClick: PropTypes.func,
};

export default LoadMore;
