import type { ComponentPropsWithoutRef } from 'react';

import classNames from 'classnames';
import { Link } from 'react-router-dom';

import type { IconProp } from '@/mastodon/components/icon';
import { Icon } from '@/mastodon/components/icon';
import { polymorphicForwardRef } from '@/types/polymorphic';

import classes from './subheading.module.scss';

export const Subheading = polymorphicForwardRef<'h2'>(
  ({ as: Component = 'h2', children, className, ...props }, ref) => {
    return (
      <Component
        ref={ref}
        className={classNames(classes.subheading, className)}
        {...props}
      >
        {children}
      </Component>
    );
  },
);

interface SubheadingLinkProps extends ComponentPropsWithoutRef<typeof Link> {
  icon: IconProp;
}

export const SubheadingLink: React.FC<SubheadingLinkProps> = ({
  icon,
  children,
  className,
  ...props
}) => {
  return (
    <Link className={classNames(classes.link, className)} {...props}>
      <Icon id='subheading-icon' icon={icon} />
      {children}
    </Link>
  );
};
