import { useCallback, useState, useEffect } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import { useParams, useHistory } from 'react-router-dom';

import { isFulfilled } from '@reduxjs/toolkit';

import { Helmet } from '@unhead/react/helmet';

import BookmarksIcon from '@/material-icons/400-24px/bookmarks-fill.svg?react';
import {
  createBookmarkFolder,
  fetchBookmarkFolder,
  updateBookmarkFolder,
} from 'mastodon/actions/bookmark_folders_typed';
import { Column } from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import { TextInputField } from 'mastodon/components/form_fields';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import type { BookmarkFolder } from 'mastodon/models/bookmark_folder';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

const messages = defineMessages({
  edit: { id: 'column.edit_bookmark_folder', defaultMessage: 'Edit folder' },
  create: {
    id: 'column.create_bookmark_folder',
    defaultMessage: 'Create folder',
  },
});

const NewBookmarkFolder: React.FC<{
  folder?: BookmarkFolder | null;
}> = ({ folder }) => {
  const dispatch = useAppDispatch();
  const history = useHistory();

  const { id, title: initialTitle = '' } = folder ?? {};

  const [title, setTitle] = useState(initialTitle);
  const [submitting, setSubmitting] = useState(false);

  const handleTitleChange = useCallback(
    ({ target: { value } }: React.ChangeEvent<HTMLInputElement>) => {
      setTitle(value);
    },
    [setTitle],
  );

  const handleSubmit = useCallback(() => {
    setSubmitting(true);

    if (id) {
      void dispatch(updateBookmarkFolder({ id, title })).then(() => {
        setSubmitting(false);
        return '';
      });
    } else {
      void dispatch(createBookmarkFolder({ title })).then((result) => {
        setSubmitting(false);

        if (isFulfilled(result)) {
          history.push(`/bookmarks/folders`);
        }

        return '';
      });
    }
  }, [dispatch, history, id, title]);

  return (
    <form className='simple_form app-form' onSubmit={handleSubmit}>
      <div className='fields-group'>
        <TextInputField
          required
          maxLength={30}
          label={
            <FormattedMessage
              id='bookmark_folders.folder_name'
              defaultMessage='Folder name'
            />
          }
          value={title}
          onChange={handleTitleChange}
          id='bookmark_folder_title'
        />
      </div>

      <div className='actions'>
        <button className='button' type='submit'>
          {submitting ? (
            <LoadingIndicator />
          ) : id ? (
            <FormattedMessage
              id='bookmark_folders.save'
              defaultMessage='Save'
            />
          ) : (
            <FormattedMessage
              id='bookmark_folders.create'
              defaultMessage='Create folder'
            />
          )}
        </button>
      </div>
    </form>
  );
};

const NewBookmarkFolderWrapper: React.FC<{
  multiColumn?: boolean;
}> = ({ multiColumn }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const { id } = useParams<{ id?: string }>();
  const folder = useAppSelector((state) =>
    id ? state.bookmark_folders.get(id) : undefined,
  );

  useEffect(() => {
    if (id) {
      void dispatch(fetchBookmarkFolder({ id }));
    }
  }, [dispatch, id]);

  const isLoading = id && !folder;

  return (
    <Column
      bindToDocument={!multiColumn}
      label={intl.formatMessage(id ? messages.edit : messages.create)}
    >
      <ColumnHeader
        title={intl.formatMessage(id ? messages.edit : messages.create)}
        icon='bookmarks'
        iconComponent={BookmarksIcon}
        multiColumn={multiColumn}
        showBackButton
      />

      <div className='scrollable'>
        {isLoading ? (
          <LoadingIndicator />
        ) : (
          <NewBookmarkFolder folder={folder} />
        )}
      </div>

      <Helmet>
        <title>
          {intl.formatMessage(id ? messages.edit : messages.create)}
        </title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default NewBookmarkFolderWrapper;
