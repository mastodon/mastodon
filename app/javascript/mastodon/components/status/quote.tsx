import type React from 'react';
import { useCallback, useEffect, useMemo, useState } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { Link } from 'react-router-dom';

import { PlayIcon } from '@phosphor-icons/react';

import { revealAccount } from '@/mastodon/actions/accounts_typed';
import { fetchStatus } from '@/mastodon/actions/statuses';
import type {
  ApiAudioAttachmentJSON,
  ApiGifvAttachmentJSON,
  ApiImageAttachmentJSON,
  ApiVideoAttachmentJSON,
} from '@/mastodon/api_types/media_attachments';
import { useToggle } from '@/mastodon/hooks/useToggle';
import { domain } from '@/mastodon/initial_state';
import type {
  AccountStatusShape,
  MediaAttachmentShape,
  QuotedStatus as TQuotedStatus,
} from '@/mastodon/models/status';
import {
  getAccountHidden as selectAccountHidden,
  selectPlainAccount,
} from '@/mastodon/selectors/accounts';
import {
  selectAccountStatus,
  selectStatusLoadingState,
} from '@/mastodon/selectors/statuses';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import type { OnElementHandler } from '@/mastodon/utils/html';

import { Avatar } from '../avatar';
import { Button } from '../button/redesign';
import { Card, CardBody, CardTitle } from '../card';
import { LinkedDisplayName } from '../display_name';
import { DisplayNameSimple } from '../display_name/simple';
import { EmojiHTML } from '../emoji/html';
import { Icon } from '../icon';
import { PopoverMenuCard } from '../menu/card';
import { RelativeTimestamp } from '../relative_timestamp';

import { StatusImage } from './image';
import classes from './quote.module.scss';

type StatusQuoteProps = TQuotedStatus & { parentId: string };

export const StatusQuote: React.FC<StatusQuoteProps> = (props) => {
  const quoteError = useQuoteError(props);

  if (quoteError) {
    return (
      <Card>
        <CardBody className={classNames(classes.body, classes.error)} noClamp>
          {quoteError}
        </CardBody>
      </Card>
    );
  }

  const quotedId = props.quoted_status;
  if (!quotedId) {
    return null;
  }

  return <QuotedStatus id={quotedId} />;
};

export const QuotedStatus: React.FC<{
  id: string;
  clamp?: boolean;
  onDelete?: () => void;
}> = ({ id, clamp, onDelete }) => {
  const status = useAppSelector((state) => selectAccountStatus(state, id));

  if (!status) {
    return null;
  }

  const statusTo = `/@${status.account.acct}/${status.id}`;

  return (
    <Card onDelete={onDelete}>
      <CardTitle
        className={classes.title}
        image={
          <Avatar
            account={status.account}
            className={classes.accountLink}
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
          className={classes.accountLink}
        />
      </CardTitle>

      <CardBody
        className={classes.body}
        as={Link}
        to={statusTo}
        noClamp={!clamp}
      >
        <QuotedStatusBody status={status} />
      </CardBody>

      {!status.spoilerHtml && <QuotedStatusLink status={status} />}
    </Card>
  );
};

const QuotedStatusBody: React.FC<{
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
      <div className={classes.spoiler}>
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
      {!!reply && <p className={classes.reply}>{reply}</p>}

      <EmojiHTML
        htmlString={status.translation?.contentHtml ?? status.contentHtml}
        extraEmojis={status.emojis}
        lang={status.translation?.language ?? status.language}
        onElement={onStatusLinks}
        extraArgs={status}
      />

      {poll && (
        <div className={classes.spoiler}>
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
          className={classNames(classes.media, classes.spoiler)}
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
        <div className={classNames(classes.media, classes.mediaSingle)}>
          <StatusImage
            className={classes.image}
            attachment={mainAttachment}
            sensitive={sensitive}
            aria-label={mainAttachment.description}
          >
            <div className={classes.videoDuration}>
              <Icon icon={PlayIcon} weight='fill' />

              {duration}
            </div>
          </StatusImage>
        </div>
      )}

      {imageAttachments.length > 0 && (
        <div
          className={classNames(
            classes.media,
            imageAttachments.length === 1 && classes.mediaSingle,
            imageAttachments.length > 1 && classes.mediaGrid,
          )}
          data-number={imageAttachments.length}
        >
          {imageAttachments.map((attachment) => (
            <StatusImage
              className={classes.image}
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

const QuotedStatusLink: React.FC<{ status: AccountStatusShape }> = ({
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

function useQuoteError({
  quoted_status: quoteId,
  state: quoteState,
  parentId,
}: StatusQuoteProps) {
  const { state: loadingState, status: quote } = useAppSelector((state) =>
    selectStatusLoadingState(state, { statusId: quoteId }),
  );
  const accountId = quote?.account.id;
  const account = useAppSelector((state) =>
    selectPlainAccount(state, accountId),
  );
  const quoteAuthorName = account?.acct;
  const domain = quoteAuthorName?.split('@')[1];
  const dispatch = useAppDispatch();
  const onRevealAccount = useCallback(() => {
    if (accountId) {
      dispatch(revealAccount({ id: accountId }));
    }
  }, [dispatch, accountId]);

  const hiddenAccount = useAppSelector(
    (state) => accountId && selectAccountHidden(state, accountId),
  );

  let message: React.ReactNode = null;
  let action: VoidFunction | null = null;
  const [reference, setReference] = useState<HTMLButtonElement | null>(null);
  const [revealed, { onTrue: onRevealQuote }] = useToggle();
  const [showInfo, { onFalse: onHideInfo, onToggle: onInfoToggle }] =
    useToggle();

  const shouldFetchQuote =
    !quote?.isLoading &&
    quoteState !== 'deleted' &&
    loadingState === 'not-found';
  useEffect(() => {
    if (shouldFetchQuote && quoteId) {
      dispatch(
        fetchStatus(quoteId, {
          parentQuotePostId: parentId,
          alsoFetchContext: false,
        }),
      );
    }
  }, [shouldFetchQuote, dispatch, quoteId, parentId]);

  if (quoteState === 'pending') {
    return (
      <>
        <FormattedMessage
          id='status.quote_error.pending_approval'
          defaultMessage='Post pending'
        />

        <Button
          size='xs'
          variant='ghost'
          onClick={onInfoToggle}
          ref={setReference}
          aria-expanded={showInfo}
          className={classes.errorButton}
        >
          <FormattedMessage
            id='learn_more_link.learn_more'
            defaultMessage='Learn more'
          />
        </Button>

        <PopoverMenuCard
          reference={reference}
          onClose={onHideInfo}
          isOpen={showInfo}
          maxWidth={200}
          className={classes.infoPopup}
          placement='bottom-end'
        >
          <FormattedMessage
            id='status.quote_error.pending_approval_popout.body'
            defaultMessage="On Mastodon, you can control whether someone can quote you. This post is pending while we're getting the original author's approval."
            tagName='p'
          />
        </PopoverMenuCard>
      </>
    );
  }

  if (loadingState === 'filtered') {
    message = (
      <FormattedMessage
        id='status.quote_error.filtered'
        defaultMessage='Hidden due to one of your filters'
      />
    );
  } else if (quoteState === 'revoked') {
    message = (
      <FormattedMessage
        id='status.quote_error.revoked'
        defaultMessage='Post removed by author'
      />
    );
  } else if (
    (quoteState === 'blocked_account' ||
      quoteState === 'blocked_domain' ||
      quoteState === 'muted_account') &&
    !revealed &&
    accountId
  ) {
    action = onRevealQuote;

    switch (quoteState) {
      case 'blocked_account':
        message = (
          <FormattedMessage
            id='status.quote_error.blocked_account_hint.title'
            defaultMessage="This post is hidden because you've blocked @{name}."
            values={{ name: quoteAuthorName }}
          />
        );
        break;
      case 'blocked_domain':
        message = (
          <FormattedMessage
            id='status.quote_error.blocked_domain_hint.title'
            defaultMessage="This post is hidden because you've blocked {domain}."
            values={{ domain }}
          />
        );
        break;
      case 'muted_account':
        message = (
          <FormattedMessage
            id='status.quote_error.muted_account_hint.title'
            defaultMessage="This post is hidden because you've muted @{name}."
            values={{ name: quoteAuthorName }}
          />
        );
    }
  } else if (
    !quote?.id ||
    quoteState === 'deleted' ||
    quoteState === 'rejected' ||
    quoteState === 'unauthorized'
  ) {
    message = (
      <FormattedMessage
        id='status.quote_error.not_available'
        defaultMessage='Post unavailable'
      />
    );
  } else if (hiddenAccount && accountId) {
    action = onRevealAccount;
    message = (
      <FormattedMessage
        id='status.quote_error.limited_account_hint.title'
        defaultMessage='This account has been hidden by the moderators of {domain}.'
        values={{ domain }}
      />
    );
  }

  if (!message) {
    return null;
  }

  return (
    <>
      {message}

      {action && (
        <Button
          size='xs'
          variant='ghost'
          onClick={action}
          className={classes.errorButton}
        >
          <FormattedMessage
            id='status.quote_error.limited_account_hint.action'
            defaultMessage='Show anyway'
          />
        </Button>
      )}
    </>
  );
}
