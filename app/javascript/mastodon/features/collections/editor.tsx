import { useCallback, useState, useEffect } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';
import { useParams, useHistory } from 'react-router-dom';

import { isFulfilled } from '@reduxjs/toolkit';

import ListAltIcon from '@/material-icons/400-24px/list_alt.svg?react';
import type {
  ApiCollectionJSON,
  ApiCreateCollectionPayload,
  ApiUpdateCollectionPayload,
} from 'mastodon/api_types/collections';
import { Button } from 'mastodon/components/button';
import { Column } from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import { TextAreaField, ToggleField } from 'mastodon/components/form_fields';
import { TextInputField } from 'mastodon/components/form_fields/text_input_field';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import {
  createCollection,
  fetchCollection,
  updateCollection,
} from 'mastodon/reducers/slices/collections';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

const messages = defineMessages({
  edit: { id: 'column.edit_collection', defaultMessage: 'Edit collection' },
  create: {
    id: 'column.create_collection',
    defaultMessage: 'Create collection',
  },
});

const CollectionSettings: React.FC<{
  collection?: ApiCollectionJSON | null;
}> = ({ collection }) => {
  const dispatch = useAppDispatch();
  const history = useHistory();

  const {
    id,
    name: initialName = '',
    description: initialDescription = '',
    tag,
    discoverable: initialDiscoverable = true,
    sensitive: initialSensitive = false,
  } = collection ?? {};

  const [name, setName] = useState(initialName);
  const [description, setDescription] = useState(initialDescription);
  const [topic, setTopic] = useState(tag?.name ?? '');
  const [discoverable] = useState(initialDiscoverable);
  const [sensitive, setSensitive] = useState(initialSensitive);

  const handleNameChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      setName(event.target.value);
    },
    [],
  );

  const handleDescriptionChange = useCallback(
    (event: React.ChangeEvent<HTMLTextAreaElement>) => {
      setDescription(event.target.value);
    },
    [],
  );

  const handleTopicChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      setTopic(event.target.value);
    },
    [],
  );

  const handleSensitiveChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      setSensitive(event.target.checked);
    },
    [],
  );

  const handleSubmit = useCallback(
    (e: React.FormEvent) => {
      e.preventDefault();

      if (id) {
        const payload: ApiUpdateCollectionPayload = {
          id,
          name,
          description,
          tag_name: topic,
          discoverable,
          sensitive,
        };

        void dispatch(updateCollection({ payload })).then(() => {
          history.push(`/collections`);
        });
      } else {
        const payload: ApiCreateCollectionPayload = {
          name,
          description,
          discoverable,
          sensitive,
        };
        if (topic) {
          payload.tag_name = topic;
        }

        void dispatch(
          createCollection({
            payload,
          }),
        ).then((result) => {
          if (isFulfilled(result)) {
            history.replace(
              `/collections/${result.payload.collection.id}/edit`,
            );
            history.push(`/collections`);
          }
        });
      }
    },
    [id, dispatch, name, description, topic, discoverable, sensitive, history],
  );

  return (
    <form className='simple_form app-form' onSubmit={handleSubmit}>
      <div className='fields-group'>
        <TextInputField
          required
          label={
            <FormattedMessage
              id='collections.collection_name'
              defaultMessage='Name'
            />
          }
          hint={
            <FormattedMessage
              id='collections.name_length_hint'
              defaultMessage='40 characters limit'
            />
          }
          value={name}
          onChange={handleNameChange}
          maxLength={40}
        />
      </div>

      <div className='fields-group'>
        <TextAreaField
          required
          label={
            <FormattedMessage
              id='collections.collection_description'
              defaultMessage='Description'
            />
          }
          hint={
            <FormattedMessage
              id='collections.description_length_hint'
              defaultMessage='100 characters limit'
            />
          }
          value={description}
          onChange={handleDescriptionChange}
          maxLength={100}
        />
      </div>

      <div className='fields-group'>
        <TextInputField
          required={false}
          label={
            <FormattedMessage
              id='collections.collection_topic'
              defaultMessage='Topic'
            />
          }
          hint={
            <FormattedMessage
              id='collections.topic_hint'
              defaultMessage='Add a hashtag that helps others understand the main topic of this collection.'
            />
          }
          value={topic}
          onChange={handleTopicChange}
          maxLength={40}
        />
      </div>

      <div className='fields-group'>
        <ToggleField
          label={
            <FormattedMessage
              id='collections.mark_as_sensitive'
              defaultMessage='Mark as sensitive'
            />
          }
          hint={
            <FormattedMessage
              id='collections.mark_as_sensitive_hint'
              defaultMessage="Hides the collection's description and accounts behind a content warning. The collection name will still be visible."
            />
          }
          checked={sensitive}
          onChange={handleSensitiveChange}
        />
      </div>

      <div className='actions'>
        <Button type='submit'>
          {id ? (
            <FormattedMessage id='lists.save' defaultMessage='Save' />
          ) : (
            <FormattedMessage id='lists.create' defaultMessage='Create' />
          )}
        </Button>
      </div>
    </form>
  );
};

export const CollectionEditorPage: React.FC<{
  multiColumn?: boolean;
}> = ({ multiColumn }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const { id } = useParams<{ id?: string }>();
  const collection = useAppSelector((state) =>
    id ? state.collections.collections[id] : undefined,
  );
  const isEditMode = !!id;
  const isLoading = isEditMode && !collection;

  useEffect(() => {
    if (id) {
      void dispatch(fetchCollection({ collectionId: id }));
    }
  }, [dispatch, id]);

  const pageTitle = intl.formatMessage(id ? messages.edit : messages.create);

  return (
    <Column bindToDocument={!multiColumn} label={pageTitle}>
      <ColumnHeader
        title={pageTitle}
        icon='list-ul'
        iconComponent={ListAltIcon}
        multiColumn={multiColumn}
        showBackButton
      />

      <div className='scrollable'>
        {isLoading ? (
          <LoadingIndicator />
        ) : (
          <CollectionSettings collection={collection} />
        )}
      </div>

      <Helmet>
        <title>{pageTitle}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};
