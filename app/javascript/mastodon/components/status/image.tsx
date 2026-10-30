import { useCallback } from 'react';

import classNames from 'classnames';

import { openAttachmentGallery } from '@/mastodon/actions/interactions_typed';
import type {
  ApiGifvAttachmentJSON,
  ApiImageAttachmentJSON,
  ApiVideoAttachmentJSON,
} from '@/mastodon/api_types/media_attachments';
import { Blurhash } from '@/mastodon/components/blurhash';
import { useBlurhash } from '@/mastodon/initial_state';
import type { MediaAttachmentShape } from '@/mastodon/models/status';
import { useAppDispatch } from '@/mastodon/store';
import type { PolymorphicProps } from '@/types/polymorphic';

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
  children?: React.ReactNode;
  sensitive?: boolean;
  showAlt?: boolean;
  autoPlay?: boolean;
  style?: React.CSSProperties;
  className?: string;
}

export const StatusImage = <As extends React.ElementType = 'div'>({
  as: asComp,
  attachment,
  children,
  sensitive,
  className,
  style,
  showAlt = false,
  ...props
}: PolymorphicProps<StatusImageProps, As>) => {
  const Comp = asComp ?? 'div';
  let x = 50;
  let y = 50;
  const focusX = attachment.meta?.focus?.x;
  const focusY = attachment.meta?.focus?.y;
  if (focusX && focusY) {
    x = (focusX / 2 + 0.5) * 100;
    y = (focusY / -2 + 0.5) * 100;
  }

  const width = attachment.meta?.original?.width;
  const height = attachment.meta?.original?.height;

  const imgStyle = {
    backgroundImage:
      !sensitive && attachment.preview_url
        ? `url(${attachment.preview_url})`
        : undefined,
    backgroundPosition: `${x}% ${y}%`,
    '--aspect': width && height ? `${width} / ${height}` : undefined,
    ...style,
  };

  return (
    <Comp
      {...props}
      className={classNames(classes.image, className)}
      style={imgStyle}
      data-color-scheme='dark'
    >
      {sensitive && attachment.blurhash && (
        <Blurhash
          hash={attachment.blurhash}
          className={classes.blurHash}
          dummy={!useBlurhash}
        />
      )}

      {children}

      {attachment.description && showAlt && (
        <AltTextBadge
          description={attachment.description}
          className={classes.imageAltBadge}
        />
      )}
    </Comp>
  );
};

export const StatusGalleryImage: React.FC<
  StatusImageProps & { statusId: string }
> = ({ statusId, attachment, ...props }) => {
  const dispatch = useAppDispatch();
  const handleClick: React.MouseEventHandler<HTMLAnchorElement> = useCallback(
    (event) => {
      if (
        event.target instanceof HTMLElement &&
        event.target !== event.currentTarget &&
        event.target.closest('a, button, input')
      ) {
        event.preventDefault();
        return;
      }

      if (event.button === 0 && !(event.ctrlKey || event.metaKey)) {
        event.preventDefault();
        dispatch(
          openAttachmentGallery({ statusId, attachmentId: attachment.id }),
        );
      }

      event.stopPropagation();
    },
    [attachment.id, dispatch, statusId],
  );
  return (
    <StatusImage
      as='a'
      href={attachment.remote_url ?? attachment.url}
      attachment={attachment}
      onClick={handleClick}
      target='_blank'
      rel='noopener'
      {...props}
    />
  );
};
