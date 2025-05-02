import { useEffect } from 'react';

import { getAverageFromBlurhash } from 'mastodon/blurhash';
import type { RGB } from 'mastodon/blurhash';
import { Audio } from 'mastodon/features/audio';
import { Footer } from 'mastodon/features/picture_in_picture/components/footer';
import type { MediaAttachment } from 'mastodon/models/media_attachment';
import { useAppSelector } from 'mastodon/store';

const AudioModal: React.FC<{
  media: MediaAttachment;
  statusId: string;
  options: {
    autoPlay: boolean;
  };
  onClose: () => void;
  onChangeBackgroundColor: (color: RGB | null) => void;
}> = ({ media, statusId, options, onClose, onChangeBackgroundColor }) => {
  const status = useAppSelector((state) => state.statuses.get(statusId));
  const accountId = status?.get('account') as string | undefined;
  const accountStaticAvatar = useAppSelector((state) =>
    accountId ? state.accounts.get(accountId)?.avatar_static : undefined,
  );

  useEffect(() => {
    const backgroundColor = getAverageFromBlurhash(
      media.get('blurhash') as string | null,
    );

    onChangeBackgroundColor(backgroundColor ?? { r: 255, g: 255, b: 255 });

    return () => {
      onChangeBackgroundColor(null);
    };
  }, [media, onChangeBackgroundColor]);

  const language = (status?.getIn(['translation', 'language']) ??
    status?.get('language')) as string;
  const description = (media.getIn(['translation', 'description']) ??
    media.get('description')) as string;

  return (
    <div className='modal-root__modal audio-modal'>
      <div className='audio-modal__container'>
        <Audio
          src={media.get('url') as string}
          alt={description}
          lang={language}
          poster={
            (media.get('preview_url') as string | null) ?? accountStaticAvatar
          }
          duration={media.getIn(['meta', 'original', 'duration'], 0) as number}
          backgroundColor={
            media.getIn(['meta', 'colors', 'background']) as string
          }
          foregroundColor={
            media.getIn(['meta', 'colors', 'foreground']) as string
          }
          accentColor={media.getIn(['meta', 'colors', 'accent']) as string}
          startPlaying={options.autoPlay}
        />
      </div>

      <div className='media-modal__overlay'>
        {status && (
          <Footer
            statusId={status.get('id') as string}
            withOpenButton
            onClose={onClose}
          />
        )}
      </div>
    </div>
  );
};

// eslint-disable-next-line import/no-default-export
export default AudioModal;
