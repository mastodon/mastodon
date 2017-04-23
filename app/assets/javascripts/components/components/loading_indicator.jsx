import { FormattedMessage } from 'react-intl';

const LoadingIndicator = () => (
  <div className='loading-indicator'>
    <FormattedMessage id='loading_indicator.label' defaultMessage='Loading...' />
  </div>
);

export default LoadingIndicator;
