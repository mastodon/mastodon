import * as React from 'react';
import classNames from 'classnames';
import { autoPlayGif } from '../initial_state';
import { useHovering } from '../../hooks/useHovering';
import type { Account } from '../../types/resources';

type Props = {
  account: Account;
  size: number;
  style?: React.CSSProperties;
  inline?: boolean;
  animate?: boolean;
};

export const Avatar: React.FC<Props> = ({
  account,
  animate = autoPlayGif,
  size = 20,
  inline = false,
  style: styleFromParent,
}) => {
  const { hovering, handleMouseEnter, handleMouseLeave } = useHovering(animate);

  const style = {
    ...styleFromParent,
    width: `${size}px`,
    height: `${size}px`,
  };

  const src =
    hovering || animate
      ? account?.get('avatar')
      : account?.get('avatar_static');

  return (
    <div
      className={classNames('account__avatar', {
        'account__avatar-inline': inline,
      })}
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
      style={style}
    >
      {src && <img src={src} alt={account?.get('acct')} />}
    </div>
  );
};
