import { FormattedMessage } from 'react-intl';

const MemorialNote = () => (
  <div className='account-memorial-banner'>
    <div className='account-memorial-banner__message'>
      <FormattedMessage id='account.in_memoriam' defaultMessage='In Memoriam.' />
    </div>
  </div>
);

export default MemorialNote;
