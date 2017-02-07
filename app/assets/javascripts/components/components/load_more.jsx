import { FormattedMessage } from 'react-intl';

const loadMoreStyle = {
  display: 'block',
  color: '#616b86',
  textAlign: 'center',
  padding: '15px',
  textDecoration: 'none'
};

const LoadMore = ({ onClick }) => (
  <a href='#' className='load-more' onClick={onClick} style={loadMoreStyle}>
    <FormattedMessage id='status.load_more' defaultMessage='Load more' />
  </a>
);

LoadMore.propTypes = {
  onClick: React.PropTypes.func
};

export default LoadMore;
