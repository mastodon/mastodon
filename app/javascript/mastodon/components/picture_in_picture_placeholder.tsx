import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import PipExitIcon from '@/material-icons/400-24px/pip_exit.svg?react';
import { removePictureInPicture } from 'mastodon/actions/picture_in_picture';
import { Icon } from 'mastodon/components/icon';
import { useAppDispatch } from 'mastodon/store';

export const PictureInPicturePlaceholder: React.FC<{ aspectRatio: string }> = ({
  aspectRatio,
}) => {
  const dispatch = useAppDispatch();

  const handleClick = useCallback(() => {
    dispatch(removePictureInPicture());
  }, [dispatch]);

  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent) => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        e.stopPropagation();
        handleClick();
      }
    },
    [handleClick],
  );

  return (
    <div /* eslint-disable-line jsx-a11y/click-events-have-key-events */
      className='picture-in-picture-placeholder'
      style={{ aspectRatio }}
      role='button'
      tabIndex={0}
      onClick={handleClick}
      onKeyDownCapture={handleKeyDown}
    >
      <Icon id='' icon={PipExitIcon} />
      <FormattedMessage
        id='picture_in_picture.restore'
        defaultMessage='Put it back'
      />
    </div>
  );
};
