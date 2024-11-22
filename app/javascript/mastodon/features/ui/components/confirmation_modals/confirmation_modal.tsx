import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { Button } from 'mastodon/components/button';

export interface BaseConfirmationModalProps {
  onClose: () => void;
}

export const ConfirmationModal: React.FC<
  {
    title: React.ReactNode;
    message: React.ReactNode;
    confirm: React.ReactNode;
    secondary?: React.ReactNode;
    onSecondary?: () => void;
    onConfirm: () => void;
    closeWhenConfirm?: boolean;
  } & BaseConfirmationModalProps
> = ({
  title,
  message,
  confirm,
  onClose,
  onConfirm,
  secondary,
  onSecondary,
  closeWhenConfirm = true,
}) => {
  const handleClick = useCallback(() => {
    if (closeWhenConfirm) {
      onClose();
    }

    onConfirm();
  }, [onClose, onConfirm, closeWhenConfirm]);

  const handleSecondary = useCallback(() => {
    onClose();
    onSecondary?.();
  }, [onClose, onSecondary]);

  const handleCancel = useCallback(() => {
    onClose();
  }, [onClose]);

  return (
    <div className='modal-root__modal safety-action-modal'>
      <div className='safety-action-modal__top'>
        <div className='safety-action-modal__confirmation'>
          <h1>{title}</h1>
          <p>{message}</p>
        </div>
      </div>

      <div className='safety-action-modal__bottom'>
        <div className='safety-action-modal__actions'>
          {secondary && (
            <>
              <Button onClick={handleSecondary}>{secondary}</Button>

              <div className='spacer' />
            </>
          )}

          <button onClick={handleCancel} className='link-button'>
            <FormattedMessage
              id='confirmation_modal.cancel'
              defaultMessage='Cancel'
            />
          </button>

          {/* eslint-disable-next-line jsx-a11y/no-autofocus -- we are in a modal and thus autofocusing is justified */}
          <Button onClick={handleClick} autoFocus>
            {confirm}
          </Button>
        </div>
      </div>
    </div>
  );
};
