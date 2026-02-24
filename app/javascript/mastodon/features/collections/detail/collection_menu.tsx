import { useCallback, useMemo } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { matchPath } from 'react-router';

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
  more: { id: 'status.more', defaultMessage: 'More' },
});

export const CollectionMenu: React.FC<{
  collection: ApiCollectionJSON;
  context: 'list' | 'collection';
  className?: string;
}> = ({ collection, context, className }) => {
  const dispatch = useAppDispatch();
  const intl = useIntl();

  const { id, name, account_id } = collection;
  const isOwnCollection = account_id === me;
  const ownerAccount = useAccount(account_id);

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

  const menu = useMemo(() => {
    if (isOwnCollection) {
      const commonItems: MenuItem[] = [
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
        return [
          { text: intl.formatMessage(messages.view), to: `/collections/${id}` },
          null,
          ...commonItems,
        ];
      } else {
        return commonItems;
      }
    } else if (ownerAccount) {
      const items: MenuItem[] = [
        {
          text: intl.formatMessage(messages.report),
          action: openReportModal,
        },
      ];
      const featuredCollectionsPath = `/@${ownerAccount.acct}/featured`;
      // Don't show menu link to featured collections while on that very page
      if (
        !matchPath(location.pathname, {
          path: featuredCollectionsPath,
          exact: true,
        })
      ) {
        items.unshift(
          ...[
            {
              text: intl.formatMessage(messages.viewOtherCollections),
              to: featuredCollectionsPath,
            },
            null,
          ],
        );
      }
      return items;
    } else {
      return [];
    }
  }, [
    isOwnCollection,
    intl,
    id,
    openDeleteConfirmation,
    context,
    ownerAccount,
    openReportModal,
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
