import { FormattedMessage } from 'react-intl';

import {
  Card as MediaCard,
  CardDescription,
} from '@/mastodon/features/status/components/card';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useToggle } from '@/mastodon/hooks/useToggle';
import { useBlurhash } from '@/mastodon/initial_state';
import type { CardShape, ExpandedStatusShape } from '@/mastodon/models/status';
import { decodeIDNA } from '@/mastodon/utils/links';

import { Avatar } from '../avatar';
import { Blurhash } from '../blurhash';
import { Button } from '../button/redesign';
import {
  Card,
  CardActions,
  CardBody,
  CardTitle,
  PrimaryCardLink,
} from '../card';
import { DisplayName } from '../display_name';
import { RelativeTimestamp } from '../relative_timestamp';

import classes from './attachments.module.scss';

export const LinkCard: React.FC<{
  card: CardShape;
  status: ExpandedStatusShape;
}> = ({ card, status }) => {
  // Use the old card if we have authors as the new design doesn't have attribution yet.
  if (card.type === 'video') {
    return <LinkEmbedCard card={card} status={status} />;
  }

  const providerUrl = new URL(card.provider_url || card.url);

  const authors = card.authors
    .map(({ accountId }) => accountId)
    .filter((id): id is string => !!id);

  return (
    <Card
      image={card.image && <LinkCardImage card={card} />}
      lang={card.language ?? undefined}
    >
      <CardTitle
        afterContent={
          card.published_at && (
            <RelativeTimestamp timestamp={card.published_at} />
          )
        }
      >
        <a
          href={`${providerUrl.protocol}//${providerUrl.host}`}
          target='_blank'
          rel='noopener'
        >
          {card.provider_name || decodeIDNA(providerUrl.host)}
        </a>
      </CardTitle>
      <CardBody>
        <PrimaryCardLink href={card.url} target='_blank' rel='noopener'>
          {card.title}
        </PrimaryCardLink>
      </CardBody>
      {card.description && (
        <CardBody isDescription>{card.description}</CardBody>
      )}

      {authors.length > 0 && (
        <CardActions>
          <FormattedMessage
            id='status.link_preview.authors'
            defaultMessage='{count, plural, one {Find the author in the Fediverse:} other {Find the authors in the Fediverse:}}'
            values={{
              count: authors.length,
            }}
            tagName='span'
          />

          {authors.map((accountId) => (
            <LinkCardAuthor authorId={accountId} key={accountId} />
          ))}
        </CardActions>
      )}
    </Card>
  );
};

const LinkCardImage: React.FC<{ card: CardShape }> = ({ card }) => {
  const [loaded, { onTrue: onLoad }] = useToggle();
  if (!card.image) {
    return null;
  }

  return (
    <>
      <img src={card.image} alt={card.image_description} onLoad={onLoad} />
      {!loaded && card.blurhash && <Blurhash hash={card.blurhash} />}
    </>
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

const LinkEmbedCard: React.FC<{
  card: CardShape;
  status: ExpandedStatusShape;
}> = ({ card, status }) => {
  const [hidden, { onFalse: onShow }] = useToggle(status.sensitive);

  if (hidden) {
    return (
      <div className={classes.cardMedia}>
        <div className={classes.cardMediaSpoiler}>
          <Blurhash hash={card.blurhash} dummy={!useBlurhash} />

          {!status.hidden && (
            <div
              className={classes.gallerySpoiler}
              data-interactive-post-content='true'
            >
              <Button size='sm' variant='solid' onClick={onShow}>
                <FormattedMessage
                  id='content_warning.media.show_short'
                  defaultMessage='Show media'
                />
              </Button>
            </div>
          )}
        </div>

        <CardDescription card={card} />
      </div>
    );
  }

  return (
    <div className={classes.cardMedia}>
      <MediaCard key={`${status.id}-${status.edited_at}`} card={card} />
    </div>
  );
};
