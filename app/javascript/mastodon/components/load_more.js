import React from 'react';
import { FormattedMessage } from 'react-intl';
import PropTypes from 'prop-types';

const LoadMore = ({ onClick }) => (
  <a href="#" className='load-more' role='button' onClick={onClick}>
    <FormattedMessage id='status.load_more' defaultMessage='Load more' />
  </a>
);

LoadMore.propTypes = {
  onClick: PropTypes.func,
};

export default LoadMore;
