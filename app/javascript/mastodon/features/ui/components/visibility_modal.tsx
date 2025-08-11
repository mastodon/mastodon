import type { FC } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { IconButton } from '@/mastodon/components/icon_button';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
});

export const VisibilityModal: FC<{
  statusId?: string;
  onClose: () => void;
}> = ({ onClose }) => {
  const intl = useIntl();
  return (
    <div className='modal-root__modal dialog-modal'>
      <div className='dialog-modal__header'>
        <IconButton
          className='dialog-modal__header__close'
          title={intl.formatMessage(messages.close)}
          icon='times'
          iconComponent={CloseIcon}
          onClick={onClose}
        />
        <span className='dialog-modal__header__title'>
          <FormattedMessage
            id='visibility_modal.header'
            defaultMessage='Visibility and Interaction'
          />
        </span>
      </div>
      <div className='dialog-modal__content'>
        <div className='dialog-modal__content__form'>
          <div className='dialog-modal__content__form__description'>
            <FormattedMessage
              id='visibility_modal.instructions'
              defaultMessage='Control who can interact with this post. Global settings can be found under <link>Preferences > Other.</link>'
              values={{
                link: (chunks) => (
                  <a href='/settings/preferences/other'>{chunks}</a>
                ),
              }}
            />
          </div>
        </div>
      </div>
    </div>
  );
};
