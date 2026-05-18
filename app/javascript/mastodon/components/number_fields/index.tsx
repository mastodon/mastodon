import classNames from 'classnames';
import { NavLink } from 'react-router-dom';

import type { MastodonLocationDescriptor } from 'mastodon/components/router';

import classes from './styles.module.scss';

export const NumberFields: React.FC<React.ComponentPropsWithoutRef<'ul'>> = ({
  children,
  className,
}) => {
  return <ul className={classNames(classes.list, className)}>{children}</ul>;
};

interface ItemProps extends React.ComponentPropsWithoutRef<'li'> {
  label: React.ReactNode;
  hint?: string;
  link?: MastodonLocationDescriptor;
}

export const NumberFieldsItem: React.FC<ItemProps> = ({
  label,
  hint,
  link,
  children,
  className,
  ...restProps
}) => {
  return (
    <li
      {...restProps}
      className={classNames(classes.item, className)}
      title={hint}
    >
      {label}
      {link ? (
        <NavLink exact to={link}>
          {children}
        </NavLink>
      ) : (
        <strong>{children}</strong>
      )}
    </li>
  );
};
