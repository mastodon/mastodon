import { useState, useCallback } from 'react';

import classNames from 'classnames';
import { Link } from 'react-router-dom';

import { useHovering } from 'mastodon/hooks/useHovering';
import { autoPlayGif } from 'mastodon/initial_state';
import type { Account } from 'mastodon/models/account';

interface Props {
  account:
    | Pick<Account, 'id' | 'acct' | 'avatar' | 'avatar_static'>
    | undefined; // FIXME: remove `undefined` once we know for sure its always there
  size?: number;
  style?: React.CSSProperties;
  inline?: boolean;
  animate?: boolean;
  withLink?: boolean;
  counter?: number | string;
  counterBorderColor?: string;
  className?: string;
}

export const Avatar: React.FC<Props> = ({
  account,
  animate = autoPlayGif,
  size = 20,
  inline = false,
  withLink = false,
  style: styleFromParent,
  className,
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

  const src = hovering || animate ? account?.avatar : account?.avatar_static;

  const handleLoad = useCallback(() => {
    setLoading(false);
  }, [setLoading]);

  const handleError = useCallback(() => {
    setError(true);
  }, [setError]);

  const avatar = (
    <span
      className={classNames(className, 'account__avatar', {
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
        <span
          className='account__avatar__counter'
          style={{ borderColor: counterBorderColor }}
        >
          {counter}
        </span>
      )}
    </span>
  );

  if (withLink) {
    return (
      <Link
        to={`/@${account?.acct}`}
        title={`@${account?.acct}`}
        data-hover-card-account={account?.id}
      >
        {avatar}
      </Link>
    );
  }

  return avatar;
};
