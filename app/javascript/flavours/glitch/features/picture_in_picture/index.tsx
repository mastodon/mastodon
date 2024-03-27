import { useCallback } from 'react';

import classNames from 'classnames';

import { removePictureInPicture } from 'flavours/glitch/actions/picture_in_picture';
import Audio from 'flavours/glitch/features/audio';
import Video from 'flavours/glitch/features/video';
import {
  useAppDispatch,
  useAppSelector,
} from 'flavours/glitch/store/typed_functions';

import Footer from './components/footer';
import { Header } from './components/header';

export const PictureInPicture: React.FC = () => {
  const dispatch = useAppDispatch();

  const handleClose = useCallback(() => {
    dispatch(removePictureInPicture());
  }, [dispatch]);

  const pipState = useAppSelector((s) => s.picture_in_picture);

  const left = useAppSelector(
    // @ts-expect-error - `local_settings` is not yet typed
    // eslint-disable-next-line @typescript-eslint/no-unsafe-call
    (s) => s.getIn(['local_settings', 'media', 'pop_in_position']) === 'left',
  );

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
    <div className={classNames('picture-in-picture', { left })}>
      <Header accountId={accountId} statusId={statusId} onClose={handleClose} />

      {player}

      <Footer statusId={statusId} />
    </div>
  );
};
