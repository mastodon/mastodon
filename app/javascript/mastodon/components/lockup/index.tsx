import classNames from 'classnames';
import type { LinkProps } from 'react-router-dom';
import { Link } from 'react-router-dom';

import type { PolymorphicProps } from '@/types/polymorphic';

import classes from './styles.module.scss';

interface LockupWrapperProps extends Omit<
  React.ComponentPropsWithRef<'div'>,
  'title'
> {
  icon?: React.ReactNode;
  sideContent?: React.ReactNode;
}

/**
 * A lockup is a combination of an image or icon and some accompanying text on its
 * side. It's often used as the basis for repeated list items or inside of cards to
 * represent distinct items (accounts, collections) in the UI.
 *
 * Choose the child of the wrapper component based on needed interactivity:
 * `LockupContent` for a non-interactive item, `LockupButton` or `LockupLink`
 * for interactive items.
 */
export const LockupWrapper: React.FC<LockupWrapperProps> = ({
  icon,
  sideContent,
  children,
  className,
  ...otherProps
}) => {
  return (
    <div {...otherProps} className={classNames(classes.wrapper, className)}>
      {icon}
      <div className={classes.main}>{children}</div>
      {sideContent && (
        <span className={classes.sideContent}>{sideContent}</span>
      )}
    </div>
  );
};

interface LockupContentProps {
  subtitle?: React.ReactNode;
  subtitleId?: string;
}

export const LockupContent = <As extends React.ElementType = 'h3'>({
  as,
  subtitle,
  subtitleId,
  children,
  ...otherProps
}: PolymorphicProps<LockupContentProps, As>) => {
  const Component = as ?? 'h3';
  return (
    <>
      <Component className={classes.title} {...otherProps}>
        {children}
      </Component>
      {subtitle && (
        <div className={classes.subtitle} id={subtitleId}>
          {subtitle}
        </div>
      )}
    </>
  );
};

interface LockupLinkProps extends LinkProps, LockupContentProps {
  isHotkeyNavigationTarget?: boolean;
  as?: React.ElementType;
}

export const LockupLink = ({
  as,
  subtitle,
  subtitleId,
  children,
  className,
  isHotkeyNavigationTarget = true,
  ...otherProps
}: LockupLinkProps) => {
  return (
    <LockupContent as={as ?? 'h3'} subtitle={subtitle} subtitleId={subtitleId}>
      <Link
        className={classNames(
          className,
          isHotkeyNavigationTarget && 'focusable',
        )}
        {...otherProps}
      >
        {children}
      </Link>
    </LockupContent>
  );
};

interface LockupButtonProps
  extends React.ComponentPropsWithRef<'button'>, LockupContentProps {
  isHotkeyNavigationTarget?: boolean;
  as?: React.ElementType;
}

export const LockupButton = ({
  as,
  subtitle,
  subtitleId,
  children,
  className,
  isHotkeyNavigationTarget = true,
  ...otherProps
}: LockupButtonProps) => {
  const Comp = as ?? 'h3';
  return (
    <LockupContent as={Comp} subtitle={subtitle} subtitleId={subtitleId}>
      <button
        type='button'
        className={classNames(
          className,
          isHotkeyNavigationTarget && 'focusable',
        )}
        {...otherProps}
      >
        {children}
      </button>
    </LockupContent>
  );
};
