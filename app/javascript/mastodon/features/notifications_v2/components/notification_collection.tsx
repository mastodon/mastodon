import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { DisplayNameSimple } from '@/mastodon/components/display_name/simple';
import { Icon } from '@/mastodon/components/icon';
import { useAccount } from '@/mastodon/hooks/useAccount';
import CollectionsFilledIcon from '@/material-icons/400-24px/category-fill.svg?react';
import type {
  NotificationGroupAddedToCollection,
  NotificationGroupCollectionUpdate,
} from 'mastodon/models/notification_group';

import { CollectionPreviewCard } from '../../collections/components/collection_preview_card';

export const NotificationCollection: React.FC<{
  notification:
    | NotificationGroupAddedToCollection
    | NotificationGroupCollectionUpdate;
  unread: boolean;
}> = ({ notification, unread }) => {
  const { collection, type } = notification;
  const collectionCreatorAccount = useAccount(collection.account_id);

  return (
    <div
      className={classNames(
        'notification-group',
        `notification-group--${type}`,
        { 'notification-group--unread': unread },
      )}
    >
      <div className='notification-group__icon'>
        <Icon id='collection' icon={CollectionsFilledIcon} />
      </div>

      <div className='notification-group__main'>
        <div className='notification-group__main__header'>
          <div className='notification-group__main__header__label'>
            {type === 'added_to_collection' && (
              <FormattedMessage
                id='notification.added_to_collection'
                defaultMessage='{name} added you to a collection'
                values={{
                  name: (
                    <DisplayNameSimple account={collectionCreatorAccount} />
                  ),
                }}
              />
            )}
            {type === 'collection_update' && (
              <FormattedMessage
                id='notification.collection_update'
                defaultMessage='{name} edited a collection you’re in'
                values={{
                  name: (
                    <DisplayNameSimple account={collectionCreatorAccount} />
                  ),
                }}
              />
            )}
          </div>
        </div>

        <CollectionPreviewCard collection={collection} />
      </div>
    </div>
  );
};
