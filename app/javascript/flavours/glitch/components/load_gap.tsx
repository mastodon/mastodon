import { useCallback } from 'react';

import type { InjectedIntl } from 'react-intl';
import { injectIntl, defineMessages } from 'react-intl';

import { Icon } from 'flavours/glitch/components/icon';

const messages = defineMessages({
  load_more: { id: 'status.load_more', defaultMessage: 'Load more' },
});

interface Props {
  disabled: boolean;
  maxId: string;
  onClick: (maxId: string) => void;
  intl: InjectedIntl;
}

const _LoadGap: React.FC<Props> = ({ disabled, maxId, onClick, intl }) => {
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

export const LoadGap = injectIntl(_LoadGap);
