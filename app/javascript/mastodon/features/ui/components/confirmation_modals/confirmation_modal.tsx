import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { Button } from 'mastodon/components/button';

export interface BaseConfirmationModalProps {
  onClose: () => void;
}

export const ConfirmationModal: React.FC<
  {
    title: React.ReactNode;
    titleId?: string;
    message?: React.ReactNode;
    confirm: React.ReactNode;
    cancel?: React.ReactNode;
    secondary?: React.ReactNode;
    onSecondary?: () => void;
    onConfirm: () => void;
    noCloseOnConfirm?: boolean;
    extraContent?: React.ReactNode;
    children?: React.ReactNode;
    updating?: boolean;
    disabled?: boolean;
    noFocusButton?: boolean;
  } & BaseConfirmationModalProps
> = ({
  title,
  titleId,
  message,
  confirm,
  cancel,
  onClose,
  onConfirm,
  secondary,
  onSecondary,
  extraContent,
  children,
  updating,
  disabled,
  noCloseOnConfirm = false,
  noFocusButton = false,
}) => {
  const handleClick = useCallback(() => {
    if (!noCloseOnConfirm) {
      onClose();
    }

    onConfirm();
  }, [onClose, onConfirm, noCloseOnConfirm]);

  const handleSecondary = useCallback(() => {
    onClose();
    onSecondary?.();
  }, [onClose, onSecondary]);

  return (
    <div className='modal-root__modal safety-action-modal'>
      <div className='safety-action-modal__top'>
        <div className='safety-action-modal__confirmation'>
          <h1 id={titleId}>{title}</h1>
          {message && <p>{message}</p>}

          {extraContent ?? children}
        </div>
      </div>

      <div className='safety-action-modal__bottom'>
        <div className='safety-action-modal__actions'>
          <button onClick={onClose} className='link-button' type='button'>
            {cancel ?? (
              <FormattedMessage
                id='confirmation_modal.cancel'
                defaultMessage='Cancel'
              />
            )}
          </button>

          {secondary && (
            <>
              <div className='spacer' />
              <button
                onClick={handleSecondary}
                className='link-button'
                type='button'
                disabled={disabled}
              >
                {secondary}
              </button>
            </>
          )}

          {/* eslint-disable jsx-a11y/no-autofocus -- we are in a modal and thus autofocusing is justified */}
          <Button
            onClick={handleClick}
            loading={updating}
            disabled={disabled}
            autoFocus={!noFocusButton}
          >
            {confirm}
          </Button>
          {/* eslint-enable */}
        </div>
      </div>
    </div>
  );
};
