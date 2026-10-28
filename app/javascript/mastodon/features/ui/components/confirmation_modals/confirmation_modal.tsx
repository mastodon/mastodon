import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { NavigationFocusTarget } from '@/mastodon/components/navigation_focus_target';
import { Button } from 'mastodon/components/button/redesign';
import {
  ModalShell,
  ModalShellActions,
  ModalShellBody,
} from 'mastodon/components/modal_shell';

export interface BaseConfirmationModalProps {
  onClose: () => void;
}

interface ConfirmationModalProps {
  title: React.ReactNode;
  titleId?: string;
  message?: React.ReactNode;
  confirm: React.ReactNode;
  cancel?: React.ReactNode;
  secondary?: React.ReactNode;
  onSecondary?: () => void;
  onConfirm: () => void | Promise<void>;
  noCloseOnConfirm?: boolean;
  extraContent?: React.ReactNode;
  children?: React.ReactNode;
  className?: string;
  updating?: boolean;
  disabled?: boolean;
  noFocusButton?: boolean;
}

export const ConfirmationModal: React.FC<
  ConfirmationModalProps & BaseConfirmationModalProps
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
  className,
  updating,
  disabled,
  noCloseOnConfirm = false,
  noFocusButton = false,
}) => {
  const handleSubmit = useCallback<React.SubmitEventHandler<HTMLFormElement>>(
    (e) => {
      e.preventDefault();

      if (!noCloseOnConfirm) {
        onClose();
      }

      void onConfirm();
    },
    [onClose, onConfirm, noCloseOnConfirm],
  );

  const handleSecondary = useCallback(() => {
    onClose();
    onSecondary?.();
  }, [onClose, onSecondary]);

  return (
    <ModalShell onSubmit={handleSubmit}>
      <ModalShellBody className={className}>
        {noFocusButton ? (
          <NavigationFocusTarget as='h1' id={titleId}>
            {title}
          </NavigationFocusTarget>
        ) : (
          <h1>{title}</h1>
        )}
        {message && <p>{message}</p>}

        {extraContent ?? children}
      </ModalShellBody>

      <ModalShellActions>
        <Button onClick={onClose}>
          {cancel ?? (
            <FormattedMessage
              id='confirmation_modal.cancel'
              defaultMessage='Cancel'
            />
          )}
        </Button>

        {secondary && (
          <>
            <div className='spacer' />
            <Button onClick={handleSecondary} disabled={disabled}>
              {secondary}
            </Button>
          </>
        )}

        <Button
          type='submit'
          loading={updating}
          disabled={disabled}
          autoFocus={!noFocusButton}
          variant='solid'
          color='accent'
        >
          {confirm}
        </Button>
      </ModalShellActions>
    </ModalShell>
  );
};
