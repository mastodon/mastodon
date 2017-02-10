import { FormattedMessage } from 'react-intl';

const style = {
  textAlign: 'center',
  fontSize: '16px',
  fontWeight: '500',
  paddingTop: '120px'
};

const LoadingIndicator = () => (
  <div className='loading-indicator' style={style}>
    <FormattedMessage id='loading_indicator.label' defaultMessage='Loading...' />
  </div>
);

export default LoadingIndicator;
