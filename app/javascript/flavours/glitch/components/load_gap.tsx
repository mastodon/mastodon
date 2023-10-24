import { useCallback } from 'react';

import { useIntl, defineMessages } from 'react-intl';

import { ReactComponent as MoreHorizIcon } from '@material-symbols/svg-600/outlined/more_horiz.svg';

import { Icon } from 'flavours/glitch/components/icon';

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
      <Icon id='ellipsis-h' icon={MoreHorizIcon} />
    </button>
  );
};
