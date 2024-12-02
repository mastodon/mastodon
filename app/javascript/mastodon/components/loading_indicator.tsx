import { useIntl, defineMessages } from 'react-intl';

import { CircularProgress } from './circular_progress';

const messages = defineMessages({
  loading: { id: 'loading_indicator.label', defaultMessage: 'Loading…' },
});

export const LoadingIndicator: React.FC = () => {
  const intl = useIntl();

  return (
    <div
      className='loading-indicator'
      role='progressbar'
      aria-busy
      aria-live='polite'
      aria-label={intl.formatMessage(messages.loading)}
    >
      <CircularProgress size={50} strokeWidth={6} />
    </div>
  );
};
