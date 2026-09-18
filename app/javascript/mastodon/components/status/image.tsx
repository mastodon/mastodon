import classNames from 'classnames';

import type {
  ApiGifvAttachmentJSON,
  ApiImageAttachmentJSON,
  ApiVideoAttachmentJSON,
} from '@/mastodon/api_types/media_attachments';
import { Blurhash } from '@/mastodon/components/blurhash';
import type { MediaAttachmentShape } from '@/mastodon/models/status';

import classes from './styles.module.scss';

type StatusImageAttachmentJSON =
  | ApiImageAttachmentJSON
  | ApiGifvAttachmentJSON
  | ApiVideoAttachmentJSON;

export const StatusImage: React.FC<
  {
    attachment:
      | StatusImageAttachmentJSON
      | MediaAttachmentShape<StatusImageAttachmentJSON>;
    children?: React.ReactNode;
    sensitive?: boolean;
  } & React.ComponentPropsWithRef<'div'>
> = ({ attachment, children, sensitive, className, style, ...props }) => {
  let x = 50;
  let y = 50;
  const focusX = attachment.meta.focus?.x;
  const focusY = attachment.meta.focus?.y;
  if (focusX && focusY) {
    x = (focusX / 2 + 0.5) * 100;
    y = (focusY / -2 + 0.5) * 100;
  }

  const imgStyle = {
    backgroundImage:
      !sensitive && attachment.preview_url
        ? `url(${attachment.preview_url})`
        : undefined,
    backgroundPosition: `${x}% ${y}%`,
    '--aspect': `${attachment.meta.original.width} / ${attachment.meta.original.height}`,
    ...style,
  };

  return (
    <div
      {...props}
      className={classNames(classes.contentImage, className)}
      style={imgStyle}
      data-color-scheme='dark'
    >
      {sensitive && attachment.blurhash && (
        <Blurhash
          hash={attachment.blurhash}
          className={classes.contentBlurHash}
        />
      )}

      {children}
    </div>
  );
};
