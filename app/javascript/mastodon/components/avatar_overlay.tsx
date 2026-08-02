import { useHovering } from 'mastodon/hooks/useHovering';
import { autoPlayGif } from 'mastodon/initial_state';
import type { Account, AccountShapeFull } from 'mastodon/models/account';

type AvatarAccount = Pick<
  Account | AccountShapeFull,
  'acct' | 'avatar' | 'avatar_static'
>;

interface Props {
  account?: AvatarAccount;
  friend?: AvatarAccount;
  size?: number;
  baseSize?: number;
  overlaySize?: number;
}

const handleImgLoadError = (error: { currentTarget: HTMLElement }) => {
  //
  // When the img tag fails to load the image, set the img tag to display: none. This prevents the
  // alt-text from overrunning the containing div.
  //
  error.currentTarget.style.display = 'none';
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
  const accountSrc = hovering ? account?.avatar : account?.avatar_static;
  const friendSrc = hovering ? friend?.avatar : friend?.avatar_static;

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
          {accountSrc && (
            <img
              src={accountSrc}
              alt={account?.acct}
              onError={handleImgLoadError}
            />
          )}
        </div>
      </div>
      <div className='account__avatar-overlay-overlay'>
        <div
          className='account__avatar'
          style={{ width: `${overlaySize}px`, height: `${overlaySize}px` }}
        >
          {friendSrc && (
            <img
              src={friendSrc}
              alt={friend?.acct}
              onError={handleImgLoadError}
            />
          )}
        </div>
      </div>
    </div>
  );
};
