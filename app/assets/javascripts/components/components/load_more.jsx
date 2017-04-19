import { FormattedMessage } from 'react-intl';

const LoadMore = ({ onClick }) => (
  <a href="#" className='load-more' role='button' onClick={onClick}>
    <FormattedMessage id='status.load_more' defaultMessage='Load more' />
  </a>
);

LoadMore.propTypes = {
  onClick: React.PropTypes.func
};

export default LoadMore;
