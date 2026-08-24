import type React from 'react';
import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { quoteComposeCancel } from '@/mastodon/actions/compose_typed';
import { Avatar } from '@/mastodon/components/avatar';
import { Blurhash } from '@/mastodon/components/blurhash';
import { Button } from '@/mastodon/components/button/redesign';
import { Card, CardBody, CardTitle } from '@/mastodon/components/card';
import { DisplayName } from '@/mastodon/components/display_name';
import { EmojiHTML } from '@/mastodon/components/emoji/html';
import { useHandlersForStatus } from '@/mastodon/components/status/hooks';
import { useToggle } from '@/mastodon/hooks/useToggle';
import type { AccountStatusShape } from '@/mastodon/models/status';
import { selectAccountStatus } from '@/mastodon/selectors/statuses';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import classes from './attachments.module.scss';

export const ComposeQuote: React.FC<{ id: string }> = ({ id }) => {
  const status = useAppSelector((state) => selectAccountStatus(state, id));
  const [showSensitive, { onToggle }] = useToggle();

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
    imageEle = showSensitive ? (
      <img src={image.preview_url} alt={image.description} />
    ) : (
      <Blurhash hash={image.blurhash} width={120} />
    );
  }

  return (
    <Card image={imageEle} onDelete={handleDelete}>
      <CardTitle
        image={<Avatar account={status.account} />}
        timestamp={status.created_at}
      >
        <DisplayName account={status.account} variant='noDomain' />
      </CardTitle>

      <CardBody>
        <ComposeQuoteBody
          status={status}
          showing={showSensitive}
          onToggle={onToggle}
        />
      </CardBody>
    </Card>
  );
};

const ComposeQuoteBody: React.FC<{
  onToggle: () => void;
  showing: boolean;
  status: AccountStatusShape;
}> = ({ onToggle, showing, status }) => {
  const htmlHandlers = useHandlersForStatus(status);

  const handleToggle: React.MouseEventHandler = useCallback((event) => {
    event.preventDefault();
  }, []);

  const body = (
    <EmojiHTML
      htmlString={status.translation?.contentHtml ?? status.contentHtml}
      extraEmojis={status.emojis}
      lang={status.translation?.language ?? status.language}
      {...htmlHandlers}
    />
  );

  if (!status.sensitive) {
    return body;
  }

  return (
    <details open={showing} className={classes.quoteSpoiler}>
      <summary tabIndex={-1} onClick={handleToggle}>
        <FormattedMessage
          id='compose.quote.spoiler'
          defaultMessage='Content:'
        />{' '}
        {status.spoilerHtml}
        <Button
          size='xs'
          onClick={onToggle}
          className={classes.quoteSpoilerToggle}
        >
          {showing ? (
            <FormattedMessage
              id='compose.quote.spoiler.hide'
              defaultMessage='Hide'
            />
          ) : (
            <FormattedMessage
              id='compose.quote.spoiler.show'
              defaultMessage='Show'
            />
          )}
        </Button>
      </summary>

      {body}
    </details>
  );
};
