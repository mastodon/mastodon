import * as React from 'react';

import classNames from 'classnames';

import { useHovering } from 'flavours/glitch/hooks/useHovering';
import { autoPlayGif } from 'flavours/glitch/initial_state';
import type { Account } from 'flavours/glitch/types/resources';

interface Props {
  account: Account | undefined;
  className?: string;
  size: number;
  style?: React.CSSProperties;
  inline?: boolean;
}

export const Avatar: React.FC<Props> = ({
  account,
  className,
  size = 20,
  inline = false,
  style: styleFromParent,
}) => {
  const { hovering, handleMouseEnter, handleMouseLeave } =
    useHovering(autoPlayGif);

  const style = {
    ...styleFromParent,
    width: `${size}px`,
    height: `${size}px`,
    backgroundSize: `${size}px ${size}px`,
  };

  if (account) {
    style.backgroundImage = `url(${account.get(
      hovering ? 'avatar' : 'avatar_static'
    )})`;
  }

  return (
    <div
      className={classNames(
        'account__avatar',
        { 'account__avatar-inline': inline },
        className
      )}
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
      style={style}
      data-avatar-of={account && `@${account.get('acct')}`}
      role='img'
      aria-label={account?.get('acct')}
    />
  );
};
