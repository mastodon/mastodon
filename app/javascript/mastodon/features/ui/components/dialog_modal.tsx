import type { FC, ReactNode } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import { XIcon } from '@phosphor-icons/react';

import { Button, IconButton } from '@/mastodon/components/button/redesign';
import { NavigationFocusTarget } from '@/mastodon/components/navigation_focus_target';

export type { BaseConfirmationModalProps as DialogModalProps } from './confirmation_modals/confirmation_modal';

interface DialogModalProps {
  className?: string;
  title: ReactNode;
  onClose: () => void;
  description?: ReactNode;
  wrapperClassName?: string;
  children?: ReactNode;
  noCancelButton?: boolean;
  buttons?: ReactNode;
}

export const DialogModal: FC<DialogModalProps> = ({
  className,
  title,
  onClose,
  description,
  wrapperClassName,
  children,
  noCancelButton = false,
  buttons,
}) => {
  const intl = useIntl();

  return (
    <div className={classNames('modal-root__modal dialog-modal', className)}>
      <div className='dialog-modal__header'>
        <IconButton
          className='dialog-modal__header__close'
          icon={XIcon}
          onClick={onClose}
          variant='ghost'
          size='sm'
        >
          {intl.formatMessage({
            id: 'lightbox.close',
            defaultMessage: 'Close',
          })}
        </IconButton>

        <NavigationFocusTarget as='h1' className='dialog-modal__header__title'>
          {title}
        </NavigationFocusTarget>
      </div>

      <div className='dialog-modal__content'>
        {description && (
          <div className='dialog-modal__content__description'>
            {description}
          </div>
        )}
        <div
          className={classNames(
            'dialog-modal__content__form',
            wrapperClassName,
          )}
        >
          {children}
        </div>
      </div>

      {(buttons || !noCancelButton) && (
        <div className='dialog-modal__content__actions'>
          {!noCancelButton && (
            <Button onClick={onClose}>
              <FormattedMessage
                id='confirmation_modal.cancel'
                defaultMessage='Cancel'
              />
            </Button>
          )}
          {buttons}
        </div>
      )}
    </div>
  );
};
