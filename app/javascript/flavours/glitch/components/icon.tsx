import React from 'react';

import classNames from 'classnames';

interface Props extends React.HTMLAttributes<HTMLImageElement> {
  id: string;
  className?: string;
  fixedWidth?: boolean;
  children?: never;
}

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
