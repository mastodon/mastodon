import { FormattedMessage } from 'react-intl';

const LoadMore = ({ onClick }) => (
  <span style={{ cursor: 'pointer' }} tabIndex='0' className='load-more' role='button' onClick={onClick}>
    <FormattedMessage id='status.load_more' defaultMessage='Load more' />
  </span>
);

LoadMore.propTypes = {
  onClick: React.PropTypes.func
};

export default LoadMore;
