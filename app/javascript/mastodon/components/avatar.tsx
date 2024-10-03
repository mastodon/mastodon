import classNames from 'classnames';

import type { Account } from 'mastodon/models/account';

import { useHovering } from '../../hooks/useHovering';
import { autoPlayGif } from '../initial_state';

interface Props {
  account: Account | undefined; // FIXME: remove `undefined` once we know for sure its always there
  size: number;
  style?: React.CSSProperties;
  inline?: boolean;
  animate?: boolean;
  counter?: number | string;
  counterBorderColor?: string;
}

export const Avatar: React.FC<Props> = ({
  account,
  animate = autoPlayGif,
  size = 20,
  inline = false,
  style: styleFromParent,
  counter,
  counterBorderColor,
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
      {src && <img src={src} alt='' />}
      {counter && (
        <div
          className='account__avatar__counter'
          style={{ borderColor: counterBorderColor }}
        >
          {counter}
        </div>
      )}
    </div>
  );
};
