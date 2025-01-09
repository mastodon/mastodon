import { useState, useCallback } from 'react';

import classNames from 'classnames';

import { useHovering } from 'mastodon/../hooks/useHovering';
import { autoPlayGif } from 'mastodon/initial_state';
import type { Account } from 'mastodon/models/account';

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
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  const style = {
    ...styleFromParent,
    width: `${size}px`,
    height: `${size}px`,
  };

  const src =
    hovering || animate
      ? account?.get('avatar')
      : account?.get('avatar_static');

  const handleLoad = useCallback(() => {
    setLoading(false);
  }, [setLoading]);

  const handleError = useCallback(() => {
    setError(true);
  }, [setError]);

  return (
    <div
      className={classNames('account__avatar', {
        'account__avatar--inline': inline,
        'account__avatar--loading': loading,
      })}
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
      style={style}
    >
      {src && !error && (
        <img src={src} alt='' onLoad={handleLoad} onError={handleError} />
      )}

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
