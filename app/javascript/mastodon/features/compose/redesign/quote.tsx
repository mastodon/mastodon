import type React from 'react';
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
import { DisplayNameSimple } from '@/mastodon/components/display_name/simple';
import { EmojiHTML } from '@/mastodon/components/emoji/html';
import { Icon } from '@/mastodon/components/icon';
import { RelativeTimestamp } from '@/mastodon/components/relative_timestamp';
import { domain } from '@/mastodon/initial_state';
import type {
  MediaAttachmentShape,
  AccountStatusShape,
} from '@/mastodon/models/status';
import { selectPlainAccount } from '@/mastodon/selectors/accounts';
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
        <ComposeQuoteBody status={status} />
      </CardBody>

      {!status.spoilerHtml && <ComposeQuoteLink status={status} />}
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

  const poll = useAppSelector((state) => state.polls[status.poll ?? '']);
  const inReplyToAccount = useAppSelector((state) =>
    selectPlainAccount(state, status.in_reply_to_account_id),
  );

  if (status.spoilerHtml) {
    return (
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
    );
  }

  // Show reply or thread text.
  let reply: React.ReactNode = null;
  if (status.in_reply_to_account_id === status.account.id) {
    reply = (
      <FormattedMessage
        id='status.continued_thread'
        defaultMessage='Continued thread'
      />
    );
  } else if (inReplyToAccount) {
    reply = (
      <FormattedMessage
        id='status.replied_to'
        defaultMessage='Replied to {name}'
        values={{
          name: <DisplayNameSimple account={inReplyToAccount} />,
        }}
      />
    );
  }

  return (
    <>
      {!!reply && <p className={classes.quoteReply}>{reply}</p>}

      <EmojiHTML
        htmlString={status.translation?.contentHtml ?? status.contentHtml}
        extraEmojis={status.emojis}
        lang={status.translation?.language ?? status.language}
        onElement={onStatusLinks}
        extraArgs={status}
      />

      {poll && (
        <div className={classes.quoteSpoiler}>
          <FormattedMessage
            id='compose.quote.poll'
            defaultMessage='Poll {sep} {isOpen, select, open {Accepting responses} other {Closed}}'
            values={{
              isOpen: poll.expired ? 'closed' : 'open',
              sep: <>&bull;</>,
            }}
          />
        </div>
      )}

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

const ComposeQuoteLink: React.FC<{ status: AccountStatusShape }> = ({
  status,
}) => {
  const quotedPost = useAppSelector((state) =>
    selectAccountStatus(state, status.quote?.quoted_status),
  );

  let link: React.ReactNode = null;

  if (quotedPost) {
    link = (
      <Link to={`/@${quotedPost.account.acct}/${quotedPost.id}`}>
        {quotedPost.uri}
      </Link>
    );
  }

  if (status.card) {
    if (new URL(status.card.url).host === domain) {
      link = <Link to={status.card.url}>{status.card.url}</Link>;
    } else {
      link = (
        <a href={status.card.url} target='_blank' rel='noopener'>
          {status.card.url}
        </a>
      );
    }
  }

  const collection = status.tagged_collections[0];
  if (collection) {
    link = <Link to={`/collections/${collection.id}`}>{collection.url}</Link>;
  }

  if (!link) {
    return null;
  }

  return <CardBody>{link}</CardBody>;
};

const onStatusLinks: OnElementHandler<AccountStatusShape> = (
  element,
  { key, href },
  children,
  status,
) => {
  // If this is a paragraph with just a link and it matches the card, don't add it.
  if (
    element instanceof HTMLParagraphElement &&
    element.children.length === 1 &&
    element.firstChild instanceof HTMLAnchorElement &&
    element.firstChild.href === status.card?.url
  ) {
    return null;
  } else if (element instanceof HTMLAnchorElement) {
    if (href === status.card?.url) {
      return null;
    }
    return <strong key={key as string}>{children}</strong>;
  }
  return undefined;
};
