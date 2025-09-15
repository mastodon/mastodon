import { Avatar } from 'mastodon/components/avatar';
import { useHovering } from 'mastodon/hooks/useHovering';
import { autoPlayGif } from 'mastodon/initial_state';
import type { Account } from 'mastodon/models/account';

interface Props {
  account: Account | undefined; // FIXME: remove `undefined` once we know for sure its always there
  friend: Account | undefined; // FIXME: remove `undefined` once we know for sure its always there
  size?: number;
  baseSize?: number;
  overlaySize?: number;
}

export const AvatarOverlay: React.FC<Props> = ({
  account,
  friend,
  size = 46,
  baseSize = 36,
  overlaySize = 24,
}) => {
  const { hovering, handleMouseEnter, handleMouseLeave } =
    useHovering(autoPlayGif);

  return (
    <div
      className='account__avatar-overlay'
      style={{ width: size, height: size }}
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
    >
      <div className='account__avatar-overlay-base'>
        <Avatar
          account={account}
          size={baseSize}
          animate={hovering || autoPlayGif}
        />
      </div>

      <div className='account__avatar-overlay-overlay'>
        <Avatar
          account={friend}
          size={overlaySize}
          animate={hovering || autoPlayGif}
        />
      </div>
    </div>
  );
};
