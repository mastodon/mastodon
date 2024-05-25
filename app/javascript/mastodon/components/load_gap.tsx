import { useCallback } from 'react';

import { useIntl, defineMessages } from 'react-intl';

import { Icon } from 'mastodon/components/icon';

const messages = defineMessages({
  load_more: { id: 'status.load_more', defaultMessage: 'Load more' },
});

interface Props {
  disabled: boolean;
  maxId: string;
  onClick: (maxId: string) => void;
}

export const LoadGap: React.FC<Props> = ({ disabled, maxId, onClick }) => {
  const intl = useIntl();

  const handleClick = useCallback(() => {
    onClick(maxId);
  }, [maxId, onClick]);

  return (
    <button
      className='load-more load-gap'
      disabled={disabled}
      onClick={handleClick}
      aria-label={intl.formatMessage(messages.load_more)}
    >
      <Icon id='ellipsis-h' />
    </button>
  );
};
