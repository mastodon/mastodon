import React from 'react';
import classNames from 'classnames';

type Props = {
  id: string;
  className?: string;
  fixedWidth?: boolean;
  children?: never;
  [key: string]: any;
};
export const Icon: React.FC<Props> = ({
  id,
  className,
  fixedWidth,
  ...other
}) => (
  <i
    className={classNames('fa', `fa-${id}`, className, { 'fa-fw': fixedWidth })}
    {...other}
  />
);
