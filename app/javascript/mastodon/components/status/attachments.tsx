import { lazy, Suspense, useCallback, useRef, useState } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { openModal } from '@/mastodon/actions/modal';
import type { DeployPictureInPictureCallback } from '@/mastodon/actions/picture_in_picture';
import { deployPictureInPicture } from '@/mastodon/actions/picture_in_picture';
import { CollectionPreviewCard } from '@/mastodon/features/collections/components/collection_preview_card';
import MediaCard from '@/mastodon/features/status/components/card';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useExpandedStatus } from '@/mastodon/hooks/useStatus';
import { displayMedia } from '@/mastodon/initial_state';
import type {
  CardShape,
  ExpandedStatusShape,
  MediaAttachment,
  MediaAttachmentShape,
} from '@/mastodon/models/status';
import { isMediaAttachmentOfType } from '@/mastodon/models/status';
import { selectMediaFilters } from '@/mastodon/selectors/filters';
import { selectPictureInPicture } from '@/mastodon/selectors/statuses';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import { compareUrls } from '@/mastodon/utils/compare_urls';
import { decodeIDNA } from '@/mastodon/utils/links';

import { Avatar } from '../avatar';
import { Button } from '../button/redesign';
import { Card, CardActions, CardBody, CardTitle } from '../card';
import { DisplayName } from '../display_name';
import { RelativeTimestamp } from '../relative_timestamp';

import classes from './attachments.module.scss';
import { useStatusContext } from './hooks';
import { PictureInPicturePlaceholder } from './legacy/picture_in_picture_placeholder';
import { StatusQuote } from './quote';
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
        sensitive={status.sensitive && !status.spoiler_text}
        language={status.translation?.language ?? status.language}
        attachment={attachment}
        restAttachments={status.media_attachments.slice(1)}
        defaultPosterUrl={status.account.avatar_static}
      />
    );
  }

  // Don't display the card or collection if this is a quote.
  if (status.quote) {
    return <StatusQuote {...status.quote} parentId={statusId} />;
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
  sensitive: boolean;
  language: string;
  attachment: MediaAttachmentShape;
  restAttachments: MediaAttachmentShape[];
  defaultPosterUrl: string;
}> = ({
  statusId,
  accountId,
  sensitive,
  language,
  attachment,
  defaultPosterUrl,
}) => {
  const description =
    attachment.translation?.description ?? attachment.description;

  const immutableAttachments = useAppSelector((state) => {
    return state.statuses.getIn([
      statusId,
      'media_attachments',
    ]) as Immutable.List<MediaAttachment>;
  });
  const { contextType } = useStatusContext();
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

  const wrapperProps = {
    sensitive,
    visible: showMedia,
    onToggle: handleToggleMediaVisibility,
    aspectRatio,
    mediaFilters,
    wrapperRef,
  } satisfies Omit<
    React.ComponentProps<typeof MediaAttachmentWrapper>,
    'children'
  >;

  if (isMediaAttachmentOfType(attachment, 'audio')) {
    const { colors, original } = attachment.meta;
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
          duration={original.duration}
          deployPictureInPicture={handleDeployPictureInPicture}
          blurhash={attachment.blurhash}
          onToggleVisibility={handleToggleMediaVisibility}
        />
      </MediaAttachmentWrapper>
    );
  }

  if (isMediaAttachmentOfType(attachment, 'video')) {
    const { original } = attachment.meta;
    return (
      <MediaAttachmentWrapper {...wrapperProps} type='video'>
        <Video
          src={attachment.url}
          alt={description}
          lang={language}
          preview={attachment.preview_url}
          frameRate={original.frame_rate}
          aspectRatio={aspectRatio}
          blurhash={attachment.blurhash}
          onOpenVideo={handleOpenVideo}
          deployPictureInPicture={handleDeployPictureInPicture}
          onToggleVisibility={handleToggleMediaVisibility}
        />
      </MediaAttachmentWrapper>
    );
  }

  return (
    <MediaAttachmentWrapper {...wrapperProps} type='media'>
      <MediaGallery
        media={immutableAttachments}
        lang={language}
        height={110}
        onOpenMedia={handleOpenMedia}
        onToggleVisibility={handleToggleMediaVisibility}
      />
    </MediaAttachmentWrapper>
  );
};

const MediaAttachmentWrapper: React.FC<{
  sensitive: boolean;
  visible: boolean;
  onToggle: () => void;
  type?: 'media' | 'video' | 'audio';
  children: React.ReactNode;
  aspectRatio: string;
  mediaFilters: string[];
  wrapperRef: React.RefObject<HTMLDivElement | null>;
}> = ({
  sensitive,
  visible,
  type = 'media',
  onToggle,
  children,
  aspectRatio,
  mediaFilters,
  wrapperRef,
}) => {
  let message = (
    <FormattedMessage id='status.media_hidden' defaultMessage='Media hidden' />
  );
  if (sensitive) {
    message = (
      <FormattedMessage
        id='status.sensitive_warning'
        defaultMessage='Sensitive content'
      />
    );
  } else if (mediaFilters.length > 0) {
    message = (
      <FormattedMessage
        id='filter_warning.matches_filter'
        defaultMessage='Matches filter “<span>{title}</span>”'
        values={{
          title: mediaFilters.join(', '),
          span: (chunks) => <span className='filter-name'>{chunks}</span>,
        }}
      />
    );
  }

  const showSpoiler = sensitive || mediaFilters.length > 0 || !visible;

  return (
    <div className={classes.galleryWrapper} ref={wrapperRef}>
      {showSpoiler && (
        <div className={classes.gallerySpoilerWrapper}>
          <span className={classes.gallerySpoilerContent}>{message}</span>
          <Button variant='solid' size='sm' onClick={onToggle}>
            {visible ? (
              <FormattedMessage
                id='content_warning.media.hide_short'
                defaultMessage='Hide media'
              />
            ) : (
              <FormattedMessage
                id='content_warning.media.show_short'
                defaultMessage='Show media'
              />
            )}
          </Button>
        </div>
      )}
      <div
        data-color-scheme='dark'
        className={classNames(
          mainClasses.contentWrapper,
          !visible && mainClasses.isFiltered,
          !visible && classes.galleryHideButtons,
        )}
      >
        <Suspense
          fallback={<div className={`media-${type}`} style={{ aspectRatio }} />}
        >
          {children}
        </Suspense>
      </div>
    </div>
  );
};

const LinkCard: React.FC<{ card: CardShape; status: ExpandedStatusShape }> = ({
  card,
  status,
}) => {
  // Use the old card if we have authors as the new design doesn't have attribution yet.
  if (card.type === 'video') {
    return (
      <div className={classes.cardMedia}>
        <MediaCard
          key={`${status.id}-${status.edited_at}`}
          card={card}
          sensitive={status.sensitive}
        />
      </div>
    );
  }

  const providerUrl = new URL(card.provider_url || card.url);

  const cardLinkProps = {
    as: 'a',
    href: card.url,
    target: '_blank',
    rel: 'noopener',
  } as const;

  return (
    <Card>
      <CardTitle
        afterContent={
          card.published_at && (
            <RelativeTimestamp timestamp={card.published_at} />
          )
        }
        lang={card.language ?? undefined}
      >
        <a
          href={`${providerUrl.protocol}//${providerUrl.host}`}
          target='_blank'
          rel='noopener'
        >
          {card.author_name ||
            card.provider_name ||
            decodeIDNA(providerUrl.host)}
        </a>
      </CardTitle>
      <CardBody {...cardLinkProps}>{card.title}</CardBody>
      {card.description && (
        <CardBody {...cardLinkProps} isDescription>
          {card.description}
        </CardBody>
      )}

      {card.authors.length > 0 && (
        <CardActions>
          <FormattedMessage
            id='status.link_preview.authors'
            defaultMessage='{count, plural, one {Find the author in the Fediverse:} other {Find the authors in the Fediverse:}}'
            values={{
              count: card.authors.length,
            }}
            tagName='span'
          />

          {card.authors.map(({ accountId }) => (
            <LinkCardAuthor authorId={accountId} key={accountId} />
          ))}
        </CardActions>
      )}
    </Card>
  );
};

const LinkCardAuthor: React.FC<{ authorId?: string }> = ({ authorId }) => {
  const author = useAccount(authorId);

  if (!author) {
    return null;
  }

  return (
    <Button
      as='link'
      size='sm'
      color='accent'
      variant='ghost'
      to={`/@${author.get('acct')}`}
      className={classes.cardAuthor}
    >
      <Avatar account={author} />
      <DisplayName variant='simple' account={author} />
    </Button>
  );
};
