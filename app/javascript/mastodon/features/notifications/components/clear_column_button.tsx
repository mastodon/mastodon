import { FormattedMessage } from 'react-intl';

import { TrashIcon } from '@phosphor-icons/react';

import { Button } from '@/mastodon/components/button/redesign';
import { isRedesignEnabled } from '@/mastodon/utils/environment';
import DeleteForeverIcon from '@/material-icons/400-24px/delete_forever.svg?react';
import { Icon } from 'mastodon/components/icon';

const ClearColumnButton: React.FC<{
  onClick: React.MouseEventHandler<HTMLButtonElement>;
}> = ({ onClick }) => {
  if (isRedesignEnabled()) {
    return (
      <Button
        size='sm'
        onClick={onClick}
        leadingIcon={TrashIcon}
        color='destructive'
        variant='ghost'
        clipPadding
      >
        <FormattedMessage
          id='notifications.clear'
          defaultMessage='Clear notifications'
        />
      </Button>
    );
  }
  return (
    <button
      type='button'
      className='text-btn column-header__setting-btn'
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

// eslint-disable-next-line import/no-default-export
export default ClearColumnButton;
