import classNames from 'classnames';
import { Link } from 'react-router-dom';

import type { PolymorphicProps } from '@/types/polymorphic';

import classes from './styles.module.scss';

interface WrapperProps extends Omit<
  React.ComponentPropsWithoutRef<'div'>,
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
export const LockupWrapper: React.FC<WrapperProps> = ({
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

interface ContentProps {
  subtitle?: React.ReactNode;
  subtitleId?: string;
}

export const LockupContent = <As extends React.ElementType = 'h3'>({
  as,
  subtitle,
  subtitleId,
  children,
  ...otherProps
}: PolymorphicProps<ContentProps, As>) => {
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

interface LinkProps
  extends React.ComponentPropsWithoutRef<typeof Link>, ContentProps {}

export const LockupLink = <As extends React.ElementType = 'h3'>({
  as,
  subtitle,
  subtitleId,
  children,
  className,
  ...otherProps
}: PolymorphicProps<LinkProps, As>) => {
  return (
    <LockupContent as={as ?? 'h3'} subtitle={subtitle} subtitleId={subtitleId}>
      <Link className={classNames(className, 'focusable')} {...otherProps}>
        {children}
      </Link>
    </LockupContent>
  );
};

interface ButtonProps
  extends React.ComponentPropsWithoutRef<'button'>, ContentProps {}

export const LockupButton = <As extends React.ElementType = 'h3'>({
  as,
  subtitle,
  subtitleId,
  children,
  className,
  ...otherProps
}: PolymorphicProps<ButtonProps, As>) => {
  const Comp = as ?? 'h3';
  return (
    <LockupContent as={Comp} subtitle={subtitle} subtitleId={subtitleId}>
      <button
        type='button'
        className={classNames(className, 'focusable')}
        {...otherProps}
      >
        {children}
      </button>
    </LockupContent>
  );
};
