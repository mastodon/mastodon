import classNames from 'classnames';

import { polymorphicForwardRef } from '@/types/polymorphic';

interface ModalShellProps {
  className?: string;
  children?: React.ReactNode;
}

export const ModalShell = polymorphicForwardRef<'form', ModalShellProps>(
  ({ as: Comp = 'form', children, className, ...restProps }, ref) => (
    <Comp
      {...restProps}
      ref={ref}
      className={classNames(
        'modal-root__modal',
        'safety-action-modal',
        className,
      )}
    >
      {children}
    </Comp>
  ),
);
ModalShell.displayName = 'ModalShell';

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
