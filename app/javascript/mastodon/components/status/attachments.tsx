import {
  lazy,
  Suspense,
  useCallback,
  useEffect,
  useRef,
  useState,
} from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { fromJS } from 'immutable';

import { EyeIcon, EyeSlashIcon } from '@phosphor-icons/react';

import { openModal } from '@/mastodon/actions/modal';
import type { DeployPictureInPictureCallback } from '@/mastodon/actions/picture_in_picture';
import { deployPictureInPicture } from '@/mastodon/actions/picture_in_picture';
import { CollectionPreviewCard } from '@/mastodon/features/collections/components/collection_preview_card';
import { useExpandedStatus } from '@/mastodon/hooks/useStatus';
import { displayMedia } from '@/mastodon/initial_state';
import type {
  MediaAttachment,
  MediaAttachmentShape,
} from '@/mastodon/models/status';
import { isMediaAttachmentOfType } from '@/mastodon/models/status';
import { selectMediaFilters } from '@/mastodon/selectors/filters';
import { selectPictureInPicture } from '@/mastodon/selectors/statuses';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import { compareUrls } from '@/mastodon/utils/compare_urls';

import { Button, IconButton } from '../button';

import classes from './attachments.module.scss';
import { useStatusContext } from './hooks';
import { LinkCard } from './link';
import { PictureInPicturePlaceholder } from './picture_in_picture_placeholder';
import mainClasses from './styles.module.scss';

export const StatusAttachments: React.FC<{
  statusId: string;
}> = ({ statusId }) => {
  const status = useExpandedStatus(statusId);

  if (!status) {
    return null;
  }

  const attachment = status.media_attachments[0];
  if (attachment) {
    return (
      <MediaAttachments
        statusId={statusId}
        accountId={status.account.id}
        statusHidden={status.hidden && !!status.spoiler_text}
        sensitive={status.sensitive}
        language={status.translation?.language ?? status.language}
        attachment={attachment}
        restAttachments={status.media_attachments.slice(1)}
        defaultPosterUrl={status.account.avatar_static}
      />
    );
  }

  const card = status.card;
  const collection = card?.url
    ? status.tagged_collections.find(({ url }) => compareUrls(url, card.url))
    : status.tagged_collections[0];
  if (card && !collection) {
    return <LinkCard card={card} status={status} />;
  }

  if (collection) {
    return <CollectionPreviewCard collection={collection} headingLevel='h2' />;
  }

  return null;
};

type OnOpenMediaCallback = (
  media: Immutable.List<MediaAttachment>,
  index: number,
  lang?: string,
) => void;

type TMediaGallery = React.ComponentClass<
  {
    media: Immutable.List<MediaAttachment>;
    height: number;
    onOpenMedia: OnOpenMediaCallback;
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
  statusHidden: boolean;
  sensitive: boolean;
  language: string;
  attachment: MediaAttachmentShape;
  restAttachments: MediaAttachmentShape[];
  defaultPosterUrl: string;
}> = ({
  statusId,
  accountId,
  statusHidden,
  sensitive,
  language,
  attachment,
  defaultPosterUrl,
  restAttachments,
}) => {
  const description =
    attachment.translation?.description ?? attachment.description;

  const immutableAttachments = useAppSelector((state) => {
    return state.statuses.getIn([
      statusId,
      'media_attachments',
    ]) as Immutable.List<MediaAttachment>;
  });
  const { contextType, registerHotkeyCallback } = useStatusContext();
  const mediaFilters = useAppSelector((state) =>
    selectMediaFilters(state, { statusId, contextType }),
  );
  const pictureInPicture = useAppSelector((state) =>
    selectPictureInPicture(state, statusId),
  );

  const wrapperRef = useRef<HTMLDivElement>(null);
  const [showMedia, setShowMedia] = useState(
    () =>
      mediaFilters.length === 0 &&
      ((displayMedia !== 'hide_all' && !sensitive) ||
        displayMedia === 'show_all'),
  );
  const handleToggleMediaVisibility = useCallback(() => {
    setShowMedia((prev) => {
      // Pause the video or audio if hiding the media
      if (prev && wrapperRef.current) {
        wrapperRef.current
          .querySelector<HTMLVideoElement | HTMLAudioElement>('video, audio')
          ?.pause();
      }
      return !prev;
    });
  }, []);

  useEffect(() => {
    registerHotkeyCallback?.('toggleSensitive', handleToggleMediaVisibility);
  }, [handleToggleMediaVisibility, registerHotkeyCallback]);

  const dispatch = useAppDispatch();
  const handleOpenMedia: OnOpenMediaCallback = useCallback(
    (media, index, lang) => {
      dispatch(
        openModal({
          modalType: 'MEDIA',
          modalProps: {
            statusId,
            media,
            index,
            lang,
          },
        }),
      );
    },
    [dispatch, statusId],
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
            media: fromJS(attachment),
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
    (isMediaAttachmentOfType(attachment, 'image') &&
      restAttachments.length === 0) ||
    isMediaAttachmentOfType(attachment, 'video') ||
    isMediaAttachmentOfType(attachment, 'gifv')
  ) {
    const width = attachment.meta?.original?.width;
    const height = attachment.meta?.original?.height;
    if (width && height) {
      aspectRatio = `${width} / ${height}`;
    }
  } else if (isMediaAttachmentOfType(attachment, 'audio')) {
    aspectRatio = '16 / 9';
  }

  if (pictureInPicture.inUse) {
    return <PictureInPicturePlaceholder aspectRatio={aspectRatio} />;
  }

  const wrapperProps = {
    visible: showMedia,
    statusHidden,
    onToggle: handleToggleMediaVisibility,
    aspectRatio,
    mediaFilters,
    wrapperRef,
  } satisfies Omit<MediaAttachmentWrapperProps, 'children'>;

  if (isMediaAttachmentOfType(attachment, 'audio')) {
    const { colors, original } = attachment.meta ?? {};
    return (
      <MediaAttachmentWrapper {...wrapperProps} type='audio'>
        <Audio
          src={attachment.url}
          alt={description}
          lang={language}
          poster={attachment.preview_url || defaultPosterUrl}
          backgroundColor={colors?.background}
          foregroundColor={colors?.foreground}
          accentColor={colors?.accent}
          duration={original?.duration}
          deployPictureInPicture={handleDeployPictureInPicture}
          blurhash={attachment.blurhash}
          onToggleVisibility={handleToggleMediaVisibility}
          visible={showMedia}
        />
      </MediaAttachmentWrapper>
    );
  }

  if (isMediaAttachmentOfType(attachment, 'video')) {
    const original = attachment.meta?.original;
    return (
      <MediaAttachmentWrapper {...wrapperProps} type='video'>
        <Video
          src={attachment.url}
          alt={description}
          lang={language}
          preview={attachment.preview_url}
          frameRate={original?.frame_rate}
          aspectRatio={aspectRatio}
          blurhash={attachment.blurhash}
          onOpenVideo={handleOpenVideo}
          deployPictureInPicture={handleDeployPictureInPicture}
          onToggleVisibility={handleToggleMediaVisibility}
          visible={showMedia}
        />
      </MediaAttachmentWrapper>
    );
  }

  return (
    <MediaAttachmentWrapper
      {...wrapperProps}
      type='gallery'
      aspectRatioForce={restAttachments.length === 0}
    >
      <MediaGallery
        media={immutableAttachments}
        lang={language}
        height={110}
        onOpenMedia={handleOpenMedia}
        visible={showMedia}
      />
    </MediaAttachmentWrapper>
  );
};

interface MediaAttachmentWrapperProps {
  visible: boolean;
  statusHidden: boolean;
  onToggle: () => void;
  type?: 'gallery' | 'video' | 'audio';
  children: React.ReactNode;
  aspectRatio: string;
  aspectRatioForce?: boolean;
  mediaFilters: string[];
  wrapperRef: React.RefObject<HTMLDivElement | null>;
}

const MediaAttachmentWrapper: React.FC<MediaAttachmentWrapperProps> = ({
  visible,
  statusHidden,
  type = 'gallery',
  onToggle,
  children,
  aspectRatio,
  aspectRatioForce,
  mediaFilters,
  wrapperRef,
}) => {
  return (
    <div
      ref={wrapperRef}
      data-color-scheme='dark'
      className={classNames(
        classes.galleryWrapper,
        aspectRatioForce && classes.galleryWrapperAspectForce,
      )}
      style={{ ['--aspect-ratio']: aspectRatio } as React.CSSProperties}
    >
      {!visible && !statusHidden && mediaFilters.length > 0 && (
        <div
          className={classNames(
            classes.gallerySpoiler,
            mediaFilters.length > 0 && classes.gallerySpoilerFilter,
          )}
          data-interactive-post-content='true'
        >
          <FormattedMessage
            id='filter_warning.matches_filter'
            defaultMessage='Matches filter “<span>{title}</span>”'
            tagName='p'
            values={{
              title: mediaFilters.join(', '),
              span: (chunks) => <span>{chunks}</span>,
            }}
          />
          <Button color='media' size='sm' onClick={onToggle}>
            <FormattedMessage
              id='content_warning.media.show_short'
              defaultMessage='Show media'
            />
          </Button>
        </div>
      )}
      <div
        className={classNames(
          mainClasses.contentWarningBlur,
          !visible && mainClasses.contentWarningBlurActive,
          !visible && classes.galleryHideActions,
          mediaFilters.length > 0 && classes.galleryFilterBlur,
        )}
      >
        <Suspense
          fallback={<div className={`media-${type}`} style={{ aspectRatio }} />}
        >
          {children}
        </Suspense>
        {(mediaFilters.length === 0 || visible) && (
          <IconButton
            icon={visible ? EyeSlashIcon : EyeIcon}
            className={classes.gallerySpoiler}
            color='media'
            size='xs'
            onClick={onToggle}
          >
            {visible ? (
              <FormattedMessage id='media_gallery.hide' defaultMessage='Hide' />
            ) : (
              <FormattedMessage
                id='content_warning.media.show_short'
                defaultMessage='Show media'
              />
            )}
          </IconButton>
        )}
      </div>
    </div>
  );
};
