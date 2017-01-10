import { FormattedMessage } from 'react-intl';

const style = {
  textAlign: 'center',
  fontSize: '16px',
  fontWeight: '500',
  color: '#616b86',
  paddingTop: '120px'
};

const MissingIndicator = () => (
  <div style={style}>
    <FormattedMessage id='missing_indicator.label' defaultMessage='Not found' />
  </div>
);

export default MissingIndicator;
