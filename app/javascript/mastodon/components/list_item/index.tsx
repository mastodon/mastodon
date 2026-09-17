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
 * A basic list item component that can be used as a base for more bespoke list items.
 *
 * Choose the child of the wrapper component based on needed interactivity:
 * `ListItemContent` for a non-interactive item, `ListItemButton` or `ListItemLink`
 * for interactive items.
 */
export const ListItemWrapper: React.FC<WrapperProps> = ({
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

export const ListItemContent = <As extends React.ElementType = 'h3'>({
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

export const ListItemLink = <As extends React.ElementType = 'h3'>({
  as,
  subtitle,
  subtitleId,
  children,
  className,
  ...otherProps
}: PolymorphicProps<LinkProps, As>) => {
  return (
    <ListItemContent
      as={as ?? 'h3'}
      subtitle={subtitle}
      subtitleId={subtitleId}
    >
      <Link className={classNames(className, 'focusable')} {...otherProps}>
        {children}
      </Link>
    </ListItemContent>
  );
};

interface ButtonProps
  extends React.ComponentPropsWithoutRef<'button'>, ContentProps {}

export const ListItemButton = <As extends React.ElementType = 'h3'>({
  as,
  subtitle,
  subtitleId,
  children,
  className,
  ...otherProps
}: PolymorphicProps<ButtonProps, As>) => {
  const Comp = as ?? 'h3';
  return (
    <ListItemContent as={Comp} subtitle={subtitle} subtitleId={subtitleId}>
      <button
        type='button'
        className={classNames(className, 'focusable')}
        {...otherProps}
      >
        {children}
      </button>
    </ListItemContent>
  );
};
