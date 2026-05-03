import { useEffect, useState, useCallback } from 'react';

import { FormattedMessage, useIntl, defineMessages } from 'react-intl';

import { isFulfilled } from '@reduxjs/toolkit';
import type { Map as ImmutableMap } from 'immutable';

import BookmarkBorderIcon from '@/material-icons/400-24px/bookmark.svg?react';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import {
  createBookmarkFolder,
  fetchBookmarkFolders,
} from 'mastodon/actions/bookmark_folders_typed';
import { bookmark } from 'mastodon/actions/interactions';
import type { ApiBookmarkFolderJSON } from 'mastodon/api_types/bookmark_folders';
import { Button } from 'mastodon/components/button';
import { RadioButton } from 'mastodon/components/form_fields';
import { Icon } from 'mastodon/components/icon';
import { IconButton } from 'mastodon/components/icon_button';
import { getOrderedBookmarkFolders } from 'mastodon/selectors/bookmark_folders';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

const messages = defineMessages({
  newFolder: {
    id: 'bookmark_folders.new_folder_name',
    defaultMessage: 'New folder name',
  },
  createFolder: {
    id: 'bookmark_folders.create',
    defaultMessage: 'Create folder',
  },
  close: {
    id: 'lightbox.close',
    defaultMessage: 'Close',
  },
  noFolder: {
    id: 'bookmark_folders.no_folder',
    defaultMessage: 'No folder',
  },
});

const FolderItem: React.FC<{
  id: string;
  title: string;
  checked: boolean;
  onChange: (id: string) => void;
}> = ({ id, title, checked, onChange }) => {
  const handleChange = useCallback(() => {
    onChange(id);
  }, [id, onChange]);

  return (
    // eslint-disable-next-line jsx-a11y/label-has-associated-control
    <label className='lists__item'>
      <div className='lists__item__title'>
        <Icon id='bookmark' icon={BookmarkBorderIcon} />
        <span>{title}</span>
      </div>

      <RadioButton
        name='bookmark-folder'
        value={id}
        checked={checked}
        onChange={handleChange}
      />
    </label>
  );
};

const NewFolderItem: React.FC<{
  onCreate: (folder: ApiBookmarkFolderJSON) => void;
}> = ({ onCreate }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const [title, setTitle] = useState('');

  const handleChange = useCallback(
    ({ target: { value } }: React.ChangeEvent<HTMLInputElement>) => {
      setTitle(value);
    },
    [setTitle],
  );

  const handleSubmit = useCallback(() => {
    if (title.trim().length === 0) {
      return;
    }

    void dispatch(createBookmarkFolder({ title })).then((result) => {
      if (isFulfilled(result)) {
        onCreate(result.payload);
        setTitle('');
      }

      return '';
    });
  }, [title, dispatch, onCreate]);

  return (
    <form className='lists__item' onSubmit={handleSubmit}>
      <label className='lists__item__title'>
        <Icon id='bookmark' icon={BookmarkBorderIcon} />

        <input
          type='text'
          value={title}
          onChange={handleChange}
          maxLength={30}
          required
          placeholder={intl.formatMessage(messages.newFolder)}
        />
      </label>

      <Button text={intl.formatMessage(messages.createFolder)} type='submit' />
    </form>
  );
};

const BookmarkFolderAdder: React.FC<{
  status: ImmutableMap<string, unknown>;
  onClose: () => void;
}> = ({ status, onClose }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const folders = useAppSelector((state) => getOrderedBookmarkFolders(state));
  const [localFolderId, setLocalFolderId] = useState<string | null>(null);
  const propFolderId =
    (status.get('bookmark_folder_id') as string | null | undefined) ?? 'none';
  const selectedFolderId = localFolderId ?? propFolderId;

  useEffect(() => {
    void dispatch(fetchBookmarkFolders());
  }, [dispatch]);

  const handleSelect = useCallback(
    (selectedId: string) => {
      setLocalFolderId(selectedId);
      dispatch(bookmark(status, selectedId === 'none' ? null : selectedId));
    },
    [dispatch, status],
  );

  const handleCreate = useCallback(
    (folder: ApiBookmarkFolderJSON) => {
      setLocalFolderId(folder.id);
      dispatch(bookmark(status, folder.id));
    },
    [dispatch, status],
  );

  return (
    <div className='modal-root__modal dialog-modal'>
      <div className='dialog-modal__header'>
        <IconButton
          className='dialog-modal__header__close'
          title={intl.formatMessage(messages.close)}
          icon='times'
          iconComponent={CloseIcon}
          onClick={onClose}
        />

        <span className='dialog-modal__header__title'>
          <FormattedMessage
            id='bookmark_folders.add_to_folder'
            defaultMessage='Add to bookmark folder'
          />
        </span>
      </div>

      <div className='dialog-modal__content'>
        <div className='lists-scrollable'>
          <NewFolderItem onCreate={handleCreate} />

          <FolderItem
            id='none'
            title={intl.formatMessage(messages.noFolder)}
            checked={selectedFolderId === 'none'}
            onChange={handleSelect}
          />

          {folders.map((folder) => (
            <FolderItem
              key={folder.id}
              id={folder.id}
              title={folder.title}
              checked={selectedFolderId === folder.id}
              onChange={handleSelect}
            />
          ))}
        </div>
      </div>
    </div>
  );
};

// eslint-disable-next-line import/no-default-export
export default BookmarkFolderAdder;
