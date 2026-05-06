import classNames from 'classnames';
import { Link } from 'react-router-dom';

import { polymorphicForwardRef } from '@/types/polymorphic';

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
      <div>{children}</div>
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

export const ListItemContent = polymorphicForwardRef<'h3', ContentProps>(
  (
    { as: Component = 'h3', subtitle, subtitleId, children, ...otherProps },
    ref,
  ) => {
    return (
      <>
        <Component className={classes.title} ref={ref} {...otherProps}>
          {children}
        </Component>
        {subtitle && (
          <div className={classes.subtitle} id={subtitleId}>
            {subtitle}
          </div>
        )}
      </>
    );
  },
);

interface LinkProps
  extends React.ComponentPropsWithoutRef<typeof Link>, ContentProps {}

export const ListItemLink = polymorphicForwardRef<'h3', LinkProps>(
  ({ as, subtitle, children, className, ...otherProps }, ref) => {
    return (
      <ListItemContent ref={ref} as={as} subtitle={subtitle}>
        <Link className={classNames(className, 'focusable')} {...otherProps}>
          {children}
        </Link>
      </ListItemContent>
    );
  },
);

interface ButtonProps
  extends React.ComponentPropsWithoutRef<'button'>, ContentProps {}

export const ListItemButton = polymorphicForwardRef<'h3', ButtonProps>(
  ({ as, subtitle, children, className, ...otherProps }, ref) => {
    return (
      <ListItemContent as={as} ref={ref} subtitle={subtitle}>
        <button
          type='button'
          className={classNames(className, 'focusable')}
          {...otherProps}
        >
          {children}
        </button>
      </ListItemContent>
    );
  },
);
