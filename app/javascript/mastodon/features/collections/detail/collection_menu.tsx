import { useCallback, useMemo } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import MoreVertIcon from '@/material-icons/400-24px/more_vert.svg?react';
import { openModal } from 'mastodon/actions/modal';
import type { ApiCollectionJSON } from 'mastodon/api_types/collections';
import { Dropdown } from 'mastodon/components/dropdown_menu';
import { IconButton } from 'mastodon/components/icon_button';
import { useAppDispatch } from 'mastodon/store';

import { messages as editorMessages } from '../editor';

const messages = defineMessages({
  view: {
    id: 'collections.view_collection',
    defaultMessage: 'View collection',
  },
  delete: {
    id: 'collections.delete_collection',
    defaultMessage: 'Delete collection',
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

  const { id, name } = collection;

  const handleDeleteClick = useCallback(() => {
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

  const menu = useMemo(() => {
    const commonItems = [
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
        action: handleDeleteClick,
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
  }, [intl, id, handleDeleteClick, context]);

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
