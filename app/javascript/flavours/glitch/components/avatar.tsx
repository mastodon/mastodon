import classNames from 'classnames';

import type { Account } from 'flavours/glitch/models/account';

import { useHovering } from '../hooks/useHovering';
import { autoPlayGif } from '../initial_state';

interface Props {
  account: Account | undefined; // FIXME: remove `undefined` once we know for sure its always there
  size: number;
  style?: React.CSSProperties;
  inline?: boolean;
  animate?: boolean;
}

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
      data-avatar-of={account && `@${account.get('acct')}`}
    >
      {src && <img src={src} alt={account?.get('acct')} />}
    </div>
  );
};
