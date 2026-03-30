import { NavLink } from 'react-router-dom';

import type { MastodonLocationDescriptor } from 'mastodon/components/router';

import classes from './styles.module.scss';

interface WrapperProps {
  children: React.ReactNode;
}

export const NumberFields: React.FC<WrapperProps> = ({ children }) => {
  return <ul className={classes.list}>{children}</ul>;
};

interface ItemProps {
  label: React.ReactNode;
  hint?: string;
  link?: MastodonLocationDescriptor;
  children: React.ReactNode;
}

export const NumberFieldsItem: React.FC<ItemProps> = ({
  label,
  hint,
  link,
  children,
}) => {
  return (
    <li className={classes.item} title={hint}>
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
