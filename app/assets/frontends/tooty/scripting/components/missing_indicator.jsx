import { FormattedMessage } from 'react-intl';

const MissingIndicator = () => (
  <div className='missing-indicator'>
    <FormattedMessage id='missing_indicator.label' defaultMessage='Not found' />
  </div>
);

export default MissingIndicator;
