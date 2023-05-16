import React, { useCallback } from 'react';
import { injectIntl, defineMessages, InjectedIntl } from 'react-intl';
import { Icon } from 'mastodon/components/icon';

const messages = defineMessages({
  load_more: { id: 'status.load_more', defaultMessage: 'Load more' },
});

type Props = {
  disabled: boolean,
  maxId: string,
  onClick: (maxId: string) => void,
  intl: InjectedIntl
};

const LoadGap: React.FC<Props> = ({ disabled, maxId, onClick, intl }) => {
  const handleClick = useCallback(() => {
    onClick(maxId);
  }, [maxId, onClick]);

  return (
    <button className='load-more load-gap' disabled={disabled} onClick={handleClick} aria-label={intl.formatMessage(messages.load_more)}>
      <Icon id='ellipsis-h' />
    </button>
  );
};

export default injectIntl(LoadGap);
