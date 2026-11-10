import { useCallback, useState } from 'react';

import classNames from 'classnames';

import { openAttachmentGallery } from '@/mastodon/actions/interactions_typed';
import type {
  ApiGifvAttachmentJSON,
  ApiImageAttachmentJSON,
  ApiVideoAttachmentJSON,
} from '@/mastodon/api_types/media_attachments';
import { Blurhash } from '@/mastodon/components/blurhash';
import { useToggle } from '@/mastodon/hooks/useToggle';
import { useBlurhash } from '@/mastodon/initial_state';
import type { MediaAttachmentShape } from '@/mastodon/models/status';
import { useAppDispatch } from '@/mastodon/store';

import { AltTextBadge } from '../alt_text_badge';

import classes from './content.module.scss';

type StatusImageAttachmentJSON =
  | ApiImageAttachmentJSON
  | ApiGifvAttachmentJSON
  | ApiVideoAttachmentJSON;

interface StatusImageProps {
  attachment:
    | StatusImageAttachmentJSON
    | MediaAttachmentShape<StatusImageAttachmentJSON>;
  statusId?: string;
  children?: React.ReactNode;
  sensitive?: boolean;
  showAlt?: boolean;
  autoPlay?: boolean;
  style?: React.CSSProperties;
  className?: string;
}

export const StatusImage: React.FC<
  StatusImageProps & React.ComponentPropsWithRef<'div'>
> = ({
  attachment,
  statusId,
  children,
  sensitive,
  className,
  style,
  showAlt = false,
  ...props
}) => {
  const [loaded, { onTrue: onLoaded }] = useToggle();

  const width = attachment.meta?.original?.width;
  const height = attachment.meta?.original?.height;

  const wrapperStyle = {
    '--aspect': width && height ? `${width} / ${height}` : undefined,
    ...style,
  };

  return (
    <div
      {...props}
      className={classNames(classes.image, className)}
      data-color-scheme='dark'
      style={wrapperStyle}
    >
      {(sensitive || !loaded) && attachment.blurhash && (
        <Blurhash
          hash={attachment.blurhash}
          className={classes.blurHash}
          dummy={!useBlurhash}
        />
      )}

      {!sensitive && (
        <StatusImageContent
          attachment={attachment}
          statusId={statusId}
          onLoaded={onLoaded}
        />
      )}

      {children}

      {attachment.description && showAlt && (
        <AltTextBadge
          description={attachment.description}
          className={classes.imageAltBadge}
        />
      )}
    </div>
  );
};

const StatusImageContent: React.FC<
  Pick<StatusImageProps, 'attachment' | 'statusId'> & { onLoaded: () => void }
> = ({ attachment, statusId, onLoaded }) => {
  const dispatch = useAppDispatch();
  const handleClick: React.MouseEventHandler<HTMLAnchorElement> = useCallback(
    (event) => {
      if (statusId && event.button === 0 && !(event.ctrlKey || event.metaKey)) {
        event.preventDefault();
        dispatch(
          openAttachmentGallery({ statusId, attachmentId: attachment.id }),
        );
      }

      event.stopPropagation();
    },
    [attachment.id, dispatch, statusId],
  );

  const { original, small, focus } = attachment.meta ?? {};

  let srcSet = '';
  if (original?.width && small?.width && attachment.type === 'image') {
    srcSet = `${attachment.url} ${original.width}w, ${attachment.preview_url} ${small.width}w`;
  }

  const [width, setWidth] = useState(0);
  const imgRef = useCallback((node: HTMLImageElement | null) => {
    if (node) {
      setWidth(node.offsetWidth);
    }
  }, []);
  let sizes = '';
  if (width > 0) {
    sizes = `${width}px`;
  }

  let x = 50;
  let y = 50;
  if (focus) {
    x = (focus.x / 2 + 0.5) * 100;
    y = (focus.y / -2 + 0.5) * 100;
  }

  let alt = attachment.description;
  if ('translation' in attachment && attachment.translation?.description) {
    alt = attachment.translation.description;
  }

  const image = (
    <img
      src={attachment.preview_url}
      alt={alt}
      srcSet={srcSet}
      sizes={sizes}
      style={{ objectPosition: `${x}% ${y}%` }}
      onLoad={onLoaded}
      ref={imgRef}
    />
  );

  if (!statusId) {
    return image;
  }

  return (
    <a
      href={attachment.remote_url ?? attachment.url}
      onClick={handleClick}
      target='_blank'
      rel='noopener'
    >
      {image}
    </a>
  );
};
