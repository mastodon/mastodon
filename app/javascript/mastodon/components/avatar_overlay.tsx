import React from 'react';
import type { Account } from '../../types/resources';
import { useHovering } from '../../hooks/useHovering';
import { autoPlayGif } from '../initial_state';

type Props = {
  account: Account;
  friend: Account;
  size?: number;
  baseSize?: number;
  overlaySize?: number;
};

export const AvatarOverlay: React.FC<Props> = ({
  account,
  friend,
  size = 46,
  baseSize = 36,
  overlaySize = 24,
}) => {
  const { hovering, handleMouseEnter, handleMouseLeave } =
    useHovering(autoPlayGif);
  const accountSrc = hovering
    ? account?.get('avatar')
    : account?.get('avatar_static');
  const friendSrc = hovering
    ? friend?.get('avatar')
    : friend?.get('avatar_static');

  return (
    <div
      className='account__avatar-overlay'
      style={{ width: size, height: size }}
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
    >
      <div className='account__avatar-overlay-base'>
        <div
          className='account__avatar'
          style={{ width: `${baseSize}px`, height: `${baseSize}px` }}
        >
          {accountSrc && <img src={accountSrc} alt={account?.get('acct')} />}
        </div>
      </div>
      <div className='account__avatar-overlay-overlay'>
        <div
          className='account__avatar'
          style={{ width: `${overlaySize}px`, height: `${overlaySize}px` }}
        >
          {friendSrc && <img src={friendSrc} alt={friend?.get('acct')} />}
        </div>
      </div>
    </div>
  );
};
