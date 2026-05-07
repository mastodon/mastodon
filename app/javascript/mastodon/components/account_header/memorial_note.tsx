import { FormattedMessage } from 'react-intl';

export const MemorialNote: React.FC = () => (
  <div className='account-memorial-banner'>
    <div className='account-memorial-banner__message'>
      <FormattedMessage
        id='account.in_memoriam'
        defaultMessage='In Memoriam.'
      />
    </div>
  </div>
);
