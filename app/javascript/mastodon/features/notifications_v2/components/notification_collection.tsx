import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { Button } from '@/mastodon/components/button';
import { LinkedDisplayName } from '@/mastodon/components/display_name';
import { Icon } from '@/mastodon/components/icon';
import { CollectionMenu } from '@/mastodon/features/collections/components/collection_menu';
import { CollectionPreviewCard } from '@/mastodon/features/collections/components/collection_preview_card';
import { useConfirmRevoke } from '@/mastodon/features/collections/detail/revoke_collection_inclusion_modal';
import { useAccount } from '@/mastodon/hooks/useAccount';
import CollectionsFilledIcon from '@/material-icons/400-24px/category-fill.svg?react';
import type {
  NotificationGroupAddedToCollection,
  NotificationGroupCollectionUpdate,
} from 'mastodon/models/notification_group';

import classes from './notification_collection.module.scss';

export const NotificationCollection: React.FC<{
  notification:
    | NotificationGroupAddedToCollection
    | NotificationGroupCollectionUpdate;
  unread: boolean;
}> = ({ notification, unread }) => {
  const { collection, type } = notification;
  const collectionCreatorAccount = useAccount(collection.account_id);
  const confirmRevoke = useConfirmRevoke(collection);

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
                    <LinkedDisplayName
                      displayProps={{
                        variant: 'simple',
                        account: collectionCreatorAccount,
                      }}
                    />
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
                    <LinkedDisplayName
                      displayProps={{
                        variant: 'simple',
                        account: collectionCreatorAccount,
                      }}
                    />
                  ),
                }}
              />
            )}
          </div>
        </div>

        <CollectionPreviewCard collection={collection} />

        <div className={classes.actions}>
          <Button
            compact
            secondary
            className='button--destructive'
            onClick={confirmRevoke}
          >
            <FormattedMessage
              id='collections.detail.revoke_inclusion'
              defaultMessage='Remove me'
            />
          </Button>

          <CollectionMenu
            context='notifications'
            collection={collection}
            className={classes.menuButton}
          />
        </div>
      </div>
    </div>
  );
};
