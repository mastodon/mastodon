import React from 'react';
import type { Account } from '../../types/resources';
import { Avatar } from './avatar';

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
}) => (
  <div className='account__avatar-overlay' style={{ width: size, height: size }}>
    <div className='account__avatar-overlay-base'><Avatar account={account} size={baseSize} /></div>
    <div className='account__avatar-overlay-overlay'><Avatar account={friend} size={overlaySize} /></div>
  </div>
);

export default AvatarOverlay;
