import { useCallback } from 'react';

import { removePictureInPicture } from 'mastodon/actions/picture_in_picture';
import Audio from 'mastodon/features/audio';
import Video from 'mastodon/features/video';
import { useAppDispatch, useAppSelector } from 'mastodon/store/typed_functions';

import Footer from './components/footer';
import { Header } from './components/header';

export const PictureInPicture: React.FC = () => {
  const dispatch = useAppDispatch();

  const handleClose = useCallback(() => {
    dispatch(removePictureInPicture());
  }, [dispatch]);

  const pipState = useAppSelector((s) => s.picture_in_picture);

  if (pipState.type === null) {
    return null;
  }

  const {
    type,
    src,
    currentTime,
    accountId,
    statusId,
    volume,
    muted,
    poster,
    backgroundColor,
    foregroundColor,
    accentColor,
  } = pipState;

  let player;

  switch (type) {
    case 'video':
      player = (
        <Video
          src={src}
          currentTime={currentTime}
          volume={volume}
          muted={muted}
          autoPlay
          inline
          alwaysVisible
        />
      );
      break;
    case 'audio':
      player = (
        <Audio
          src={src}
          currentTime={currentTime}
          volume={volume}
          muted={muted}
          poster={poster}
          backgroundColor={backgroundColor}
          foregroundColor={foregroundColor}
          accentColor={accentColor}
          autoPlay
        />
      );
  }

  return (
    <div className='picture-in-picture'>
      <Header accountId={accountId} statusId={statusId} onClose={handleClose} />

      {player}

      <Footer statusId={statusId} />
    </div>
  );
};
