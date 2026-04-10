import { useId } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { Link } from 'react-router-dom';

import WarningIcon from '@/material-icons/400-24px/warning.svg?react';
import type { ApiCollectionJSON } from 'mastodon/api_types/collections';
import { AvatarById } from 'mastodon/components/avatar';
import { useAccountHandle } from 'mastodon/components/display_name/default';
import { RelativeTimestamp } from 'mastodon/components/relative_timestamp';
import { useAccount } from 'mastodon/hooks/useAccount';
import { domain } from 'mastodon/initial_state';

import classes from './collection_lockup.module.scss';

export const AvatarGrid: React.FC<{
  accountIds: (string | undefined)[];
  sensitive?: boolean;
}> = ({ accountIds: ids, sensitive }) => {
  const avatarIds = [ids[0], ids[1], ids[2], ids[3]];
  return (
    <div
      className={classNames(
        classes.avatarGrid,
        sensitive ? classes.avatarGridSensitive : null,
      )}
    >
      {avatarIds.map((id) => (
        <AvatarById
          animate={false}
          key={id}
          accountId={id}
          className={classes.avatar}
          size={25}
        />
      ))}
      {sensitive && <WarningIcon className={classes.avatarSensitiveBadge} />}
    </div>
  );
};

export interface CollectionLockupProps {
  collection: ApiCollectionJSON;
  withAuthorHandle?: boolean;
  withTimestamp?: boolean;
}

export const CollectionLockup: React.FC<CollectionLockupProps> = ({
  collection,
  withAuthorHandle = true,
  withTimestamp,
}) => {
  const { id, name } = collection;
  const uniqueId = useId();
  const linkId = `${uniqueId}-link`;
  const infoId = `${uniqueId}-info`;
  const authorAccount = useAccount(collection.account_id);
  const authorHandle = useAccountHandle(authorAccount, domain);

  return (
    <div className={classes.content}>
      <AvatarGrid
        accountIds={collection.items.map((item) => item.account_id)}
        sensitive={collection.sensitive}
      />
      <div>
        <h2 id={linkId}>
          <Link to={`/collections/${id}`} className={classes.link}>
            {name}
          </Link>
        </h2>
        <ul className={classes.info} id={infoId}>
          {collection.sensitive && (
            <li className='sr-only'>
              <FormattedMessage
                id='collections.sensitive'
                defaultMessage='Sensitive'
              />
            </li>
          )}
          {withAuthorHandle && authorAccount && (
            <FormattedMessage
              id='collections.by_account'
              defaultMessage='by {account_handle}'
              values={{
                account_handle: authorHandle,
              }}
              tagName='li'
            />
          )}
          <FormattedMessage
            id='collections.account_count'
            defaultMessage='{count, plural, one {# account} other {# accounts}}'
            values={{ count: collection.item_count }}
            tagName='li'
          />
          {withTimestamp && (
            <FormattedMessage
              id='collections.last_updated_at'
              defaultMessage='Last updated: {date}'
              values={{
                date: (
                  <RelativeTimestamp timestamp={collection.updated_at} long />
                ),
              }}
              tagName='li'
            />
          )}
        </ul>
      </div>
    </div>
  );
};
