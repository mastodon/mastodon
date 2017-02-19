import { FormattedMessage } from 'react-intl';

const style = {
  textAlign: 'center',
  fontSize: '16px',
  fontWeight: '500',
  paddingTop: '120px'
};

const StatusNotFound = () => (
  <div className='status-not-found-indicator' style={style}>
    <FormattedMessage id='status_not_found_indicator.label' defaultMessage='Status Not Found' />
  </div>
);

export default StatusNotFound;
