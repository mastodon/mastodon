import classNames from 'classnames';

interface ModalShellProps {
  className?: string;
  children?: React.ReactNode;
}

export const ModalShell: React.FC<ModalShellProps> = ({
  children,
  className,
}) => {
  return (
    <div
      className={classNames(
        'modal-root__modal',
        'safety-action-modal',
        className,
      )}
    >
      {children}
    </div>
  );
};

export const ModalShellBody: React.FC<ModalShellProps> = ({
  children,
  className,
}) => {
  return (
    <div className='safety-action-modal__top'>
      <div
        className={classNames('safety-action-modal__confirmation', className)}
      >
        {children}
      </div>
    </div>
  );
};

export const ModalShellActions: React.FC<ModalShellProps> = ({
  children,
  className,
}) => {
  return (
    <div className='safety-action-modal__bottom'>
      <div className={classNames('safety-action-modal__actions', className)}>
        {children}
      </div>
    </div>
  );
};
