import React, { MouseEventHandler } from 'react';
import { FormattedMessage } from 'react-intl';

import DeleteForeverIcon from '@/material-icons/400-24px/delete_forever.svg?react';
import { Icon } from 'mastodon/components/icon';

interface Props {
  onClick?: MouseEventHandler<HTMLButtonElement>;
}

const ClearColumnButton: React.FC<Props> = ({ onClick }) => {
  return (
    <button
      className='text-btn column-header__setting-btn'
      tabIndex={0}
      onClick={onClick}
    >
      <Icon id='eraser' icon={DeleteForeverIcon} />{' '}
      <FormattedMessage
        id='notifications.clear'
        defaultMessage='Clear notifications'
      />
    </button>
  );
};

export default ClearColumnButton;
