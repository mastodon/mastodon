import { useCallback, useState } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';

import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import { IconButton } from 'mastodon/components/icon_button';

import { ZoomableImage } from './zoomable_image';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
});

export const ImageModal: React.FC<{
  src: string;
  alt: string;
  onClose: () => void;
}> = ({ src, alt, onClose }) => {
  const intl = useIntl();
  const [navigationHidden, setNavigationHidden] = useState(false);

  const toggleNavigation = useCallback(() => {
    setNavigationHidden((prevState) => !prevState);
  }, [setNavigationHidden]);

  const navigationClassName = classNames('media-modal__navigation', {
    'media-modal__navigation--hidden': navigationHidden,
  });

  return (
    <div className='modal-root__modal media-modal'>
      <div
        className='media-modal__closer'
        role='presentation'
        onClick={onClose}
      >
        <ZoomableImage
          src={src}
          width={400}
          height={400}
          alt={alt}
          onClick={toggleNavigation}
        />
      </div>

      <div className={navigationClassName}>
        <div className='media-modal__buttons'>
          <IconButton
            className='media-modal__close'
            title={intl.formatMessage(messages.close)}
            icon='times'
            iconComponent={CloseIcon}
            onClick={onClose}
          />
        </div>
      </div>
    </div>
  );
};
