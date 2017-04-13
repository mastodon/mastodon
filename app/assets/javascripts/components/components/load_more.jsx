import { FormattedMessage } from 'react-intl';

const LoadMore = ({ onClick }) => (
  <span className='load-more' role='button' onClick={onClick}>
    <FormattedMessage id='status.load_more' defaultMessage='Load more' />
  </span>
);

LoadMore.propTypes = {
  onClick: React.PropTypes.func
};

export default LoadMore;
