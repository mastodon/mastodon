import { lazy, Suspense, useCallback, useState } from 'react';

import { openModal } from '@/mastodon/actions/modal';
import type { DeployPictureInPictureCallback } from '@/mastodon/actions/picture_in_picture';
import { deployPictureInPicture } from '@/mastodon/actions/picture_in_picture';
import { CollectionPreviewCard } from '@/mastodon/features/collections/components/collection_preview_card';
import Card from '@/mastodon/features/status/components/card';
import { displayMedia } from '@/mastodon/initial_state';
import type {
  MediaAttachment,
  MediaAttachmentShape,
} from '@/mastodon/models/status';
import { isMediaAttachmentOfType } from '@/mastodon/models/status';
import {
  selectExpandedStatus,
  selectMediaMatchFilters,
  selectPictureInPicture,
} from '@/mastodon/selectors/statuses';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import { compareUrls } from '@/mastodon/utils/compare_urls';

import { PictureInPicturePlaceholder } from '../picture_in_picture_placeholder';

export const StatusAttachments: React.FC<{
  statusId: string;
  contextType?: string;
}> = ({ statusId, contextType }) => {
  // Selectors
  const status = useAppSelector((state) =>
    selectExpandedStatus(state, statusId),
  );

  if (!status) {
    return null;
  }

  const attachment = status.media_attachments[0];
  if (attachment) {
    return (
      <MediaAttachments
        statusId={statusId}
        accountId={status.account.id}
        contextType={contextType}
        sensitive={status.sensitive}
        language={status.translation?.language ?? status.language}
        attachment={attachment}
        restAttachments={status.media_attachments.slice(1)}
        defaultPosterUrl={status.account.avatar_static}
      />
    );
  }

  // Don't display the card or collection if this is a quote.
  if (status.quote) {
    return null;
  }

  const card = status.card;
  const collection = card?.url
    ? status.tagged_collections.find(({ url }) => compareUrls(url, card.url))
    : status.tagged_collections[0];
  if (card && !collection) {
    return (
      <Card
        key={`${status.id}-${status.edited_at}`}
        card={card}
        sensitive={status.sensitive}
      />
    );
  }

  if (collection) {
    return <CollectionPreviewCard collection={collection} headingLevel='h2' />;
  }

  return null;
};

type TMediaGallery = React.ComponentClass<
  {
    media: Immutable.List<MediaAttachment>;
    height: number;
    onOpenMedia: (index: number) => void;
    onToggleVisibility?: () => void;
    sensitive?: boolean;
    lang?: string;
    visible?: boolean;
    autoplay?: boolean;
    matchedFilters?: (string | null | undefined)[];
    cacheWidth?: () => void;
    defaultWidth?: number;
  },
  { visible: boolean; width?: number }
>;

const MediaGallery = lazy<TMediaGallery>(
  () => import('@/mastodon/components/media_gallery'),
);
const Audio = lazy(() => import('@/mastodon/features/audio'));
const Video = lazy(() => import('@/mastodon/features/video'));

const MediaAttachments: React.FC<{
  statusId: string;
  accountId: string;
  contextType?: string;
  sensitive: boolean;
  language: string;
  attachment: MediaAttachmentShape;
  restAttachments: MediaAttachmentShape[];
  defaultPosterUrl: string;
}> = ({
  statusId,
  accountId,
  contextType,
  sensitive,
  language,
  attachment,
  defaultPosterUrl,
}) => {
  const description =
    attachment.translation?.description ?? attachment.description;

  const immutableAttachments = useAppSelector(
    (state) =>
      state.statuses.getIn(
        statusId,
        'media_attachments',
      ) as Immutable.List<MediaAttachment>,
  );
  const mediaFilters = useAppSelector((state) =>
    selectMediaMatchFilters(state, { statusId, contextType }),
  );
  const pictureInPicture = useAppSelector((state) =>
    selectPictureInPicture(state, statusId),
  );

  const [showMedia, setShowMedia] = useState(
    () =>
      mediaFilters.length === 0 &&
      ((displayMedia !== 'hide_all' && !sensitive) ||
        displayMedia === 'show_all'),
  );

  const dispatch = useAppDispatch();
  const handleToggleMediaVisibility = useCallback(() => {
    setShowMedia((prev) => !prev);
  }, []);
  const handleOpenMedia = useCallback(
    (index: number) => {
      dispatch(
        openModal({
          modalType: 'MEDIA',
          modalProps: { statusId, media: attachment, index, lang: language },
        }),
      );
    },
    [attachment, dispatch, language, statusId],
  );
  const handleOpenVideo = useCallback(
    (options: {
      startTime: number;
      autoPlay: boolean;
      defaultVolume: number;
    }) => {
      dispatch(
        openModal({
          modalType: 'VIDEO',
          modalProps: {
            statusId,
            options,
            media: attachment,
            lang: language,
          },
        }),
      );
    },
    [attachment, dispatch, language, statusId],
  );
  const handleDeployPictureInPicture: DeployPictureInPictureCallback =
    useCallback(
      (type, props) => {
        if (!accountId || !pictureInPicture.available) {
          return;
        }
        void dispatch(
          deployPictureInPicture({
            statusId,
            accountId,
            playerType: type,
            props,
          }),
        );
      },
      [dispatch, pictureInPicture.available, accountId, statusId],
    );

  let aspectRatio = '3 / 2';
  if (
    isMediaAttachmentOfType(attachment, 'image') ||
    isMediaAttachmentOfType(attachment, 'video') ||
    isMediaAttachmentOfType(attachment, 'gifv')
  ) {
    aspectRatio = `${attachment.meta.original.width} / ${attachment.meta.original.height}`;
  } else if (isMediaAttachmentOfType(attachment, 'audio')) {
    aspectRatio = '16 / 9';
  }

  if (pictureInPicture.inUse) {
    return <PictureInPicturePlaceholder aspectRatio={aspectRatio} />;
  }

  if (isMediaAttachmentOfType(attachment, 'audio')) {
    const { colors, original } = attachment.meta;
    return (
      <Suspense
        fallback={<div className='audio-player' style={{ aspectRatio }} />}
      >
        <Audio
          src={attachment.url}
          alt={description}
          lang={language}
          poster={attachment.preview_url || defaultPosterUrl}
          backgroundColor={colors.background}
          foregroundColor={colors.foreground}
          accentColor={colors.accent}
          duration={original.duration}
          deployPictureInPicture={handleDeployPictureInPicture}
          sensitive={sensitive}
          blurhash={attachment.blurhash}
          visible={showMedia}
          onToggleVisibility={handleToggleMediaVisibility}
          matchedFilters={mediaFilters}
        />
      </Suspense>
    );
  }

  if (isMediaAttachmentOfType(attachment, 'video')) {
    const { original } = attachment.meta;
    return (
      <Suspense
        fallback={<div className='video-player' style={{ aspectRatio }} />}
      >
        <Video
          src={attachment.url}
          alt={description}
          lang={language}
          preview={attachment.preview_url}
          frameRate={original.frame_rate}
          aspectRatio={aspectRatio}
          blurhash={attachment.blurhash}
          sensitive={sensitive}
          onOpenVideo={handleOpenVideo}
          deployPictureInPicture={handleDeployPictureInPicture}
          visible={showMedia}
          onToggleVisibility={handleToggleMediaVisibility}
          matchedFilters={mediaFilters}
        />
      </Suspense>
    );
  }

  return (
    <Suspense
      fallback={<div className='media-player' style={{ aspectRatio }} />}
    >
      <MediaGallery
        media={immutableAttachments}
        lang={language}
        sensitive={sensitive}
        height={110}
        onOpenMedia={handleOpenMedia}
        visible={showMedia}
        onToggleVisibility={handleToggleMediaVisibility}
        matchedFilters={mediaFilters}
      />
    </Suspense>
  );
};
