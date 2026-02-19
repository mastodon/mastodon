import { useId } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { Link } from 'react-router-dom';

import type { ApiCollectionJSON } from 'mastodon/api_types/collections';
import { RelativeTimestamp } from 'mastodon/components/relative_timestamp';

import classes from './collection_list_item.module.scss';
import { CollectionMenu } from './collection_menu';

export const CollectionMetaData: React.FC<{
  collection: ApiCollectionJSON;
  extended?: boolean;
  className?: string;
}> = ({ collection, extended, className }) => {
  return (
    <ul className={classNames(classes.metaList, className)}>
      <FormattedMessage
        id='collections.account_count'
        defaultMessage='{count, plural, one {# account} other {# accounts}}'
        values={{ count: collection.item_count }}
        tagName='li'
      />
      {extended && (
        <>
          {collection.discoverable ? (
            <FormattedMessage
              id='collections.visibility_public'
              defaultMessage='Public'
              tagName='li'
            />
          ) : (
            <FormattedMessage
              id='collections.visibility_unlisted'
              defaultMessage='Unlisted'
              tagName='li'
            />
          )}
          {collection.sensitive && (
            <FormattedMessage
              id='collections.sensitive'
              defaultMessage='Sensitive'
              tagName='li'
            />
          )}
        </>
      )}
      <FormattedMessage
        id='collections.last_updated_at'
        defaultMessage='Last updated: {date}'
        values={{
          date: (
            <RelativeTimestamp
              timestamp={collection.updated_at}
              short={false}
            />
          ),
        }}
        tagName='li'
      />
    </ul>
  );
};

export const CollectionListItem: React.FC<{
  collection: ApiCollectionJSON;
}> = ({ collection }) => {
  const { id, name } = collection;
  const linkId = useId();

  return (
    <article
      className={classNames(classes.wrapper, 'focusable')}
      tabIndex={-1}
      aria-labelledby={linkId}
    >
      <div className={classes.content}>
        <h2 id={linkId}>
          <Link to={`/collections/${id}`} className={classes.link}>
            {name}
          </Link>
        </h2>
        <CollectionMetaData collection={collection} className={classes.info} />
      </div>

      <CollectionMenu context='list' collection={collection} />
    </article>
  );
};
