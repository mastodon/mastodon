import { useCallback, useMemo } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { matchPath } from 'react-router';

import { initBlockModal } from '@/mastodon/actions/blocks';
import { useAccount } from '@/mastodon/hooks/useAccount';
import MoreVertIcon from '@/material-icons/400-24px/more_vert.svg?react';
import { openModal } from 'mastodon/actions/modal';
import type { ApiCollectionJSON } from 'mastodon/api_types/collections';
import { Dropdown } from 'mastodon/components/dropdown_menu';
import { IconButton } from 'mastodon/components/icon_button';
import { me } from 'mastodon/initial_state';
import type { MenuItem } from 'mastodon/models/dropdown_menu';
import { useAppDispatch } from 'mastodon/store';

import { messages as editorMessages } from '../editor';

const messages = defineMessages({
  view: {
    id: 'collections.view_collection',
    defaultMessage: 'View collection',
  },
  viewOtherCollections: {
    id: 'collections.view_other_collections_by_user',
    defaultMessage: 'View other collections by this user',
  },
  delete: {
    id: 'collections.delete_collection',
    defaultMessage: 'Delete collection',
  },
  report: {
    id: 'collections.report_collection',
    defaultMessage: 'Report this collection',
  },
  blockOwner: {
    id: 'collections.block_collection_owner',
    defaultMessage: 'Block account',
  },
  revoke: {
    id: 'collections.revoke_collection_inclusion',
    defaultMessage: 'Remove myself from this collection',
  },
  more: { id: 'status.more', defaultMessage: 'More' },
});

export const CollectionMenu: React.FC<{
  collection: ApiCollectionJSON;
  context: 'list' | 'notifications' | 'collection';
  className?: string;
}> = ({ collection, context, className }) => {
  const dispatch = useAppDispatch();
  const intl = useIntl();

  const { id, name, account_id, items } = collection;
  const ownerAccount = useAccount(account_id);
  const isOwnCollection = account_id === me;
  const currentAccountInCollection = items.find(
    (item) => item.account_id === me,
  );

  const openDeleteConfirmation = useCallback(() => {
    dispatch(
      openModal({
        modalType: 'CONFIRM_DELETE_COLLECTION',
        modalProps: {
          name,
          id,
        },
      }),
    );
  }, [dispatch, id, name]);

  const openReportModal = useCallback(() => {
    dispatch(
      openModal({
        modalType: 'REPORT_COLLECTION',
        modalProps: {
          collection,
        },
      }),
    );
  }, [collection, dispatch]);

  const openBlockModal = useCallback(() => {
    dispatch(initBlockModal(ownerAccount));
  }, [ownerAccount, dispatch]);

  const openRevokeConfirmation = useCallback(() => {
    void dispatch(
      openModal({
        modalType: 'REVOKE_COLLECTION_INCLUSION',
        modalProps: {
          collectionId: collection.id,
          collectionItemId: currentAccountInCollection?.id,
        },
      }),
    );
  }, [collection.id, currentAccountInCollection?.id, dispatch]);

  const menu = useMemo(() => {
    const viewCollectionItem: MenuItem = {
      text: intl.formatMessage(messages.view),
      to: `/collections/${id}`,
    };
    if (isOwnCollection) {
      const ownerItems: MenuItem[] = [
        {
          text: intl.formatMessage(editorMessages.manageAccounts),
          to: `/collections/${id}/edit`,
        },
        {
          text: intl.formatMessage(editorMessages.editDetails),
          to: `/collections/${id}/edit/details`,
        },
        null,
        {
          text: intl.formatMessage(messages.delete),
          action: openDeleteConfirmation,
          dangerous: true,
        },
      ];

      if (context === 'list') {
        return [viewCollectionItem, null, ...ownerItems];
      } else {
        return ownerItems;
      }
    } else {
      const items: MenuItem[] = [viewCollectionItem];

      if (ownerAccount && context !== 'notifications') {
        const featuredCollectionsPath = `/@${ownerAccount.acct}/featured`;
        // Don't show menu link to featured collections while on that very page
        if (
          !matchPath(location.pathname, {
            path: featuredCollectionsPath,
            exact: true,
          })
        ) {
          items.push({
            text: intl.formatMessage(messages.viewOtherCollections),
            to: featuredCollectionsPath,
          });
        }
      }

      if (currentAccountInCollection) {
        items.push(null);

        // Collection notifications already have a prominent 'Remove me' button
        if (context !== 'notifications') {
          items.push({
            text: intl.formatMessage(messages.revoke),
            action: openRevokeConfirmation,
          });
        }

        items.push(
          {
            text: intl.formatMessage(messages.report),
            action: openReportModal,
          },
          {
            text: intl.formatMessage(messages.blockOwner),
            action: openBlockModal,
          },
        );
      }

      return items;
    }
  }, [
    isOwnCollection,
    intl,
    id,
    openDeleteConfirmation,
    context,
    ownerAccount,
    currentAccountInCollection,
    openReportModal,
    openBlockModal,
    openRevokeConfirmation,
  ]);

  return (
    <Dropdown scrollKey='collections' items={menu}>
      <IconButton
        icon='menu-icon'
        iconComponent={MoreVertIcon}
        title={intl.formatMessage(messages.more)}
        className={className}
      />
    </Dropdown>
  );
};
