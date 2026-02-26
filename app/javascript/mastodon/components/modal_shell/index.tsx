import classNames from 'classnames';

interface SimpleComponentProps {
  className?: string;
  children?: React.ReactNode;
}

interface ModalShellComponent extends React.FC<SimpleComponentProps> {
  Body: React.FC<SimpleComponentProps>;
  Actions: React.FC<SimpleComponentProps>;
}

export const ModalShell: ModalShellComponent = ({ children, className }) => {
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

const ModalShellBody: ModalShellComponent['Body'] = ({
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

const ModalShellActions: ModalShellComponent['Actions'] = ({
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

ModalShell.Body = ModalShellBody;
ModalShell.Actions = ModalShellActions;
