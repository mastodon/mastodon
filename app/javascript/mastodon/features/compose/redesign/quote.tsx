import type React from 'react';
import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import { quoteComposeCancel } from '@/mastodon/actions/compose_typed';
import { Avatar } from '@/mastodon/components/avatar';
import { Blurhash } from '@/mastodon/components/blurhash';
import { Card, CardBody, CardTitle } from '@/mastodon/components/card';
import { LinkedDisplayName } from '@/mastodon/components/display_name';
import { EmojiHTML } from '@/mastodon/components/emoji/html';
import { RelativeTimestamp } from '@/mastodon/components/relative_timestamp';
import type { AccountStatusShape } from '@/mastodon/models/status';
import { selectAccountStatus } from '@/mastodon/selectors/statuses';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import type { OnElementHandler } from '@/mastodon/utils/html';

import classes from './attachments.module.scss';

export const ComposeQuote: React.FC<{ id: string }> = ({ id }) => {
  const status = useAppSelector((state) => selectAccountStatus(state, id));

  const dispatch = useAppDispatch();
  const handleDelete = useCallback(() => {
    dispatch(quoteComposeCancel());
  }, [dispatch]);

  if (!status) {
    return null;
  }

  let imageEle: React.ReactNode = null;
  const image = status.media_attachments.find(({ type }) => type !== 'unknown');
  if (image) {
    imageEle = !status.sensitive ? (
      <img src={image.preview_url} alt={image.description} />
    ) : (
      <Blurhash hash={image.blurhash} width={120} />
    );
  }

  const statusTo = `/@${status.account.acct}/${status.id}`;

  return (
    <Card image={imageEle} onDelete={handleDelete}>
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
        {!status.spoiler_text ? (
          <ComposeQuoteBody status={status} />
        ) : (
          <div className={classes.quoteSpoiler}>
            <FormattedMessage
              id='compose.quote.spoiler'
              defaultMessage='Content:'
              description='Comes before user-provided spoiler description'
            />
            &nbsp;
            {status.spoiler_text}
          </div>
        )}
      </CardBody>
    </Card>
  );
};

const ComposeQuoteBody: React.FC<{
  status: AccountStatusShape;
}> = ({ status }) => {
  return (
    <EmojiHTML
      htmlString={status.translation?.contentHtml ?? status.contentHtml}
      extraEmojis={status.emojis}
      lang={status.translation?.language ?? status.language}
      onElement={onStatusLinks}
    />
  );
};

const onStatusLinks: OnElementHandler = (element, { key }, children) => {
  if (element instanceof HTMLAnchorElement) {
    return <span key={key as string}>{children}</span>;
  }
  return undefined;
};
