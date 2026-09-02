import { useCallback, useMemo } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { Link } from 'react-router-dom';

import { PlayIcon } from '@phosphor-icons/react';

import { quoteComposeCancel } from '@/mastodon/actions/compose_typed';
import type {
  ApiAudioAttachmentJSON,
  ApiGifvAttachmentJSON,
  ApiImageAttachmentJSON,
  ApiVideoAttachmentJSON,
} from '@/mastodon/api_types/media_attachments';
import { Avatar } from '@/mastodon/components/avatar';
import { Card, CardBody, CardTitle } from '@/mastodon/components/card';
import { LinkedDisplayName } from '@/mastodon/components/display_name';
import { EmojiHTML } from '@/mastodon/components/emoji/html';
import { Icon } from '@/mastodon/components/icon';
import { RelativeTimestamp } from '@/mastodon/components/relative_timestamp';
import type {
  MediaAttachmentShape,
  AccountStatusShape,
} from '@/mastodon/models/status';
import { selectAccountStatus } from '@/mastodon/selectors/statuses';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import type { OnElementHandler } from '@/mastodon/utils/html';

import classes from './attachments.module.scss';
import { ComposeImage } from './upload';

export const ComposeQuote: React.FC<{ id: string }> = ({ id }) => {
  const status = useAppSelector((state) => selectAccountStatus(state, id));

  const dispatch = useAppDispatch();
  const handleDelete = useCallback(() => {
    dispatch(quoteComposeCancel());
  }, [dispatch]);

  if (!status) {
    return null;
  }

  const statusTo = `/@${status.account.acct}/${status.id}`;

  return (
    <Card onDelete={handleDelete}>
      <CardTitle
        className={classes.quoteTitle}
        image={
          <Avatar
            account={status.account}
            className={classes.quoteAccountLink}
            withLink
          />
        }
        afterContent={
          <Link to={statusTo}>
            <RelativeTimestamp timestamp={status.created_at} />
          </Link>
        }
      >
        <LinkedDisplayName
          displayProps={{ account: status.account, variant: 'noDomain' }}
          className={classes.quoteAccountLink}
        />
      </CardTitle>

      <CardBody className={classes.quoteBody} as={Link} to={statusTo}>
        {!status.spoilerHtml ? (
          <ComposeQuoteBody status={status} />
        ) : (
          <div className={classes.quoteSpoiler}>
            <FormattedMessage
              id='compose.quote.spoiler'
              defaultMessage='Content:'
              description='Comes before user-provided spoiler description'
            />
            &nbsp;
            <EmojiHTML
              as='span'
              htmlString={status.translation?.spoilerHtml ?? status.spoilerHtml}
              lang={status.translation?.language ?? status.language}
              extraEmojis={status.emojis}
            />
          </div>
        )}
      </CardBody>
    </Card>
  );
};

const ComposeQuoteBody: React.FC<{
  status: AccountStatusShape;
}> = ({ status }) => {
  const attachments = status.media_attachments;
  const mainAttachment = attachments.find(
    (
      attachment,
    ): attachment is
      | MediaAttachmentShape<ApiAudioAttachmentJSON>
      | MediaAttachmentShape<ApiVideoAttachmentJSON> =>
      attachment.type === 'audio' || attachment.type === 'video',
  );
  const imageAttachments = attachments.filter(
    (
      attachment,
    ): attachment is MediaAttachmentShape<
      ApiImageAttachmentJSON | ApiGifvAttachmentJSON
    > => attachment.type === 'gifv' || attachment.type === 'image',
  );
  const duration = useMemo(() => {
    const duration = mainAttachment?.meta.original.duration;
    if (!duration) {
      return '';
    }
    const locale = document.documentElement.lang;
    const formatter = new Intl.DurationFormat(locale, {
      style: 'digital',
      hoursDisplay: 'auto',
    });

    const totalSeconds = Math.floor(duration);
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;

    return formatter.format({ hours, minutes, seconds });
  }, [mainAttachment?.meta.original.duration]);
  const sensitive = status.sensitive;

  return (
    <>
      <EmojiHTML
        htmlString={status.translation?.contentHtml ?? status.contentHtml}
        extraEmojis={status.emojis}
        lang={status.translation?.language ?? status.language}
        onElement={onStatusLinks}
      />

      {mainAttachment?.type === 'audio' && (
        <div
          className={classNames(classes.quoteMedia, classes.quoteSpoiler)}
          aria-label={mainAttachment.description}
        >
          <FormattedMessage
            id='compose.quote.audio'
            defaultMessage='Audio file {duration}'
            values={{
              duration: `(${duration})`,
            }}
          />
        </div>
      )}

      {mainAttachment?.type === 'video' && (
        <div className={classNames(classes.quoteMedia, classes.mediaSingle)}>
          <ComposeImage
            attachment={mainAttachment}
            sensitive={sensitive}
            aria-label={mainAttachment.description}
          >
            <div className={classes.quoteVideoDuration}>
              <Icon icon={PlayIcon} weight='fill' />

              {duration}
            </div>
          </ComposeImage>
        </div>
      )}

      {imageAttachments.length > 0 && (
        <div
          className={classNames(
            classes.quoteMedia,
            imageAttachments.length === 1 && classes.mediaSingle,
            imageAttachments.length > 1 && classes.mediaGrid,
          )}
          data-number={imageAttachments.length}
        >
          {imageAttachments.map((attachment) => (
            <ComposeImage
              attachment={attachment}
              sensitive={sensitive}
              key={attachment.id}
              aria-label={attachment.description}
            />
          ))}
        </div>
      )}
    </>
  );
};

const onStatusLinks: OnElementHandler = (element, { key }, children) => {
  if (element instanceof HTMLAnchorElement) {
    return <span key={key as string}>{children}</span>;
  }
  return undefined;
};
