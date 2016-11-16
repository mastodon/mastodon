import { FormattedMessage } from 'react-intl';

const LoadingIndicator = () => {
  const style = {
    textAlign: 'center',
    fontSize: '16px',
    fontWeight: '500',
    color: '#616b86',
    paddingTop: '120px'
  };

  return <div style={style}><FormattedMessage id='loading_indicator.label' defaultMessage='Loading...' /></div>;
};

export default LoadingIndicator;
